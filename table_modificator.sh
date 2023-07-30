#!/bin/bash

# Table modificator
#
# Copyright (c) 2023 omonomo

# 各種テーブルの修正プログラム

font_familyname="Cyroit"

cmapList="cmapList"
extList="extList"
gsubList="gsubList"

half_width="512" # 半角文字幅
full_width="1024" # 全角文字幅
underline="-80" # アンダーライン位置
#half_height="512"
#full_height="1024"
#line_gap="216"

leaving_tmp_flag="false" # 一時ファイル残す

echo
echo "- Font tables Modificator -"
echo

table_modificator_help()
{
    echo "Usage: table_modificator.sh [options]"
    echo ""
    echo "Options:"
    echo "  -h         Display this information"
    echo "  -l         Leave (do NOT remove) temporary files"
    echo "  -N string  Set fontfamily (\"string\")"
    exit 0
}

# Get options
while getopts hlN: OPT
do
    case "${OPT}" in
        "h" )
            table_modificator_help
            ;;
        "l" )
            echo "Option: Leave (do NOT remove) temporary files"
            leaving_tmp_flag="true"
            ;;
        "N" )
            echo "Option: Set fontfamily: ${OPTARG}"
            font_familyname=`echo $OPTARG | tr -d ' '`
            ;;
        * )
            exit 1
            ;;
    esac
done
shift `expr $OPTIND - 1`

# フォントがあるかチェック
fontName_ttf=`find . -name "${font_familyname}*.ttf" | head -n 1`
if [ -z "${fontName_ttf}" ]
then
  echo "Error: ${font_familyname} not found" >&2
  exit 1
fi

# ttxファイルを削除
rm -f ${font_familyname}*.ttx ${font_familyname}*.ttx.bak

for P in ${font_familyname}*.ttf; do
  ttx -t name -t head -t OS/2 -t post -t hmtx -t GSUB -t cmap "$P" # cmapは最後にする
#  ttx -t name -t head -t OS/2 -t post -t vhea -t hmtx -t vmtx -t GSUB -t cmap "$P" # cmapは最後にする (縦書き情報の取り扱いは中止)

echo "Edit tables"
  # head, OS/2 (フォントスタイルを修正)
  if [ "$(cat ${P%%.ttf}.ttx | grep "Bold Oblique")" ]; then
    sed -i.bak -e 's,macStyle value="........ ........",macStyle value="00000000 00000011",' "${P%%.ttf}.ttx"
    sed -i.bak -e 's,fsSelection value="........ ........",fsSelection value="00000010 10100001",' "${P%%.ttf}.ttx"
  elif [ "$(cat ${P%%.ttf}.ttx | grep "Oblique")" ]; then
    sed -i.bak -e 's,macStyle value="........ ........",macStyle value="00000000 00000010",' "${P%%.ttf}.ttx"
    sed -i.bak -e 's,fsSelection value="........ ........",fsSelection value="00000010 10000001",' "${P%%.ttf}.ttx"
  elif [ "$(cat ${P%%.ttf}.ttx | grep "Bold")" ]; then
    sed -i.bak -e 's,macStyle value="........ ........",macStyle value="00000000 00000001",' "${P%%.ttf}.ttx"
    sed -i.bak -e 's,fsSelection value="........ ........",fsSelection value="00000000 10100000",' "${P%%.ttf}.ttx"
  elif [ "$(cat ${P%%.ttf}.ttx | grep "Regular")" ]; then
    sed -i.bak -e 's,macStyle value="........ ........",macStyle value="00000000 00000000",' "${P%%.ttf}.ttx"
    sed -i.bak -e 's,fsSelection value="........ ........",fsSelection value="00000000 11000000",' "${P%%.ttf}.ttx"
	fi

  # head (フォントの情報を修正)
  sed -i.bak -e 's,flags value="........ ........",flags value="00000000 00000011",' "${P%%.ttf}.ttx"

  # OS/2 (全体のWidthの修正)
  sed -i.bak -e "s,xAvgCharWidth value=\"...\",xAvgCharWidth value=\"${half_width}\"," "${P%%.ttf}.ttx"

  # post (アンダーラインの位置を指定、等幅フォントであることを示す)
  sed -i.bak -e "s,underlinePosition value=\"-..\",underlinePosition value=\"${underline}\"," "${P%%.ttf}.ttx"
  sed -i.bak -e 's,isFixedPitch value=".",isFixedPitch value="1",' "${P%%.ttf}.ttx"

  # vhea (中止)
#  sed -i.bak -e "s,ascent value=\"...\",ascent value=\"${half_width}\"," "${P%%.ttf}.ttx"
#  sed -i.bak -e "s,descent value=\"-...\",descent value=\"-${half_width}\"," "${P%%.ttf}.ttx"
#  sed -i.bak -e "s,lineGap value=\"...\",lineGap value=\"${line_gap}\"," "${P%%.ttf}.ttx"

  # hmtx (Widthのブレを修正)
  sed -i.bak -e "s,width=\"3..\",width=\"0\"," "${P%%.ttf}.ttx"
  sed -i.bak -e "s,width=\"4..\",width=\"${half_width}\"," "${P%%.ttf}.ttx"
  sed -i.bak -e "s,width=\"5..\",width=\"${half_width}\"," "${P%%.ttf}.ttx"
  sed -i.bak -e "s,width=\"9..\",width=\"${full_width}\"," "${P%%.ttf}.ttx"
  sed -i.bak -e "s,width=\"1...\",width=\"${full_width}\"," "${P%%.ttf}.ttx"

  # vmtx (中止)
#  sed -i.bak -e "s,height=\"...\",height=\"${full_height}\"," "${P%%.ttf}.ttx"
#  sed -i.bak -e "s,height=\"....\",height=\"${full_height}\"," "${P%%.ttf}.ttx"

  # GSUB (用字、言語全て共通に変更)
  sed -i.bak -e '/FeatureIndex index=\"9\" value=\"..\"/d' "${P%%.ttf}.ttx"
  sed -i.bak -e "s,FeatureIndex index=\"0\" value=\".\",FeatureIndex index=\"0\" value=\"0\"," "${P%%.ttf}.ttx"
  sed -i.bak -e "s,FeatureIndex index=\"1\" value=\".\",FeatureIndex index=\"1\" value=\"3\"," "${P%%.ttf}.ttx"
  sed -i.bak -e "s,FeatureIndex index=\"2\" value=\".\",FeatureIndex index=\"2\" value=\"4\"," "${P%%.ttf}.ttx"
  sed -i.bak -e "s,FeatureIndex index=\"3\" value=\".\",FeatureIndex index=\"3\" value=\"5\"," "${P%%.ttf}.ttx"
  sed -i.bak -e "s,FeatureIndex index=\"4\" value=\".\",FeatureIndex index=\"4\" value=\"6\"," "${P%%.ttf}.ttx"
  sed -i.bak -e "s,FeatureIndex index=\"5\" value=\".\",FeatureIndex index=\"5\" value=\"7\"," "${P%%.ttf}.ttx"
  sed -i.bak -e "s,FeatureIndex index=\"6\" value=\".\",FeatureIndex index=\"6\" value=\"8\"," "${P%%.ttf}.ttx"
  sed -i.bak -e "s,FeatureIndex index=\"7\" value=\".\",FeatureIndex index=\"7\" value=\"9\"," "${P%%.ttf}.ttx"
  sed -i.bak -e "s,FeatureIndex index=\"7\" value=\"..\",FeatureIndex index=\"7\" value=\"9\"," "${P%%.ttf}.ttx"
  sed -i.bak -e "s,<FeatureIndex index=\"8\" value=\".\"\/>,<FeatureIndex index=\"8\" value=\"10\"\/>\
<FeatureIndex index=\"9\" value=\"11\"\/>," "${P%%.ttf}.ttx"
  sed -i.bak -e "s,<FeatureIndex index=\"8\" value=\"..\"\/>,<FeatureIndex index=\"8\" value=\"10\"\/>\
<FeatureIndex index=\"9\" value=\"11\"\/>," "${P%%.ttf}.ttx"

  sed -i.bak -e '/<LangSys>/{n;n;n;n;d;}' "${P%%.ttf}.ttx"
  sed -i.bak -e '/<LangSys>/{n;n;n;d;}' "${P%%.ttf}.ttx"
  sed -i.bak -e '/<LangSys>/{n;n;d;}' "${P%%.ttf}.ttx"
  sed -i.bak -e '/<LangSys>/{n;d;}' "${P%%.ttf}.ttx"
  sed -i.bak -e '/<LangSys>/d' "${P%%.ttf}.ttx"

  sed -i.bak -e '/<\/LangSys>/d' "${P%%.ttf}.ttx"
  sed -i.bak -e '/LangSysRecord/d' "${P%%.ttf}.ttx"
  sed -i.bak -e '/LangSysTag/d' "${P%%.ttf}.ttx"

  # cmap (format14を置き換える)
  sed -i.bak -e '/cmap_format_14/d' "${P%%.ttf}.ttx"
  sed -i.bak -e '/map uv=/d' "${P%%.ttf}.ttx"
  sed -i.bak -e '/<\/cmap>/d'  "${P%%.ttf}.ttx"
  sed -i.bak -e '/<\/ttFont>/d' "${P%%.ttf}.ttx"

  cat "${cmapList}.txt" >> "${P%%.ttf}.ttx"
  echo "</cmap>" >> "${P%%.ttf}.ttx"
  echo "</ttFont>" >> "${P%%.ttf}.ttx"

done
echo

# テーブル更新
for P in ${font_familyname}*.ttf; do
  mv "$P" "${P%%.ttf}.orig.ttf"
  ttx -m "${P%%.ttf}.orig.ttf" "${P%%.ttf}.ttx"
done
echo

# 一時ファイルを削除
echo "Remove temporary files"
rm -f ${font_familyname}*.orig.ttf
rm -f ${font_familyname}*.ttx.bak
if [ "${leaving_tmp_flag}" = "false" ]
then
  rm -f ${font_familyname}*.ttx
  rm -f ${cmapList}.txt
  rm -f ${extList}.txt
  rm -f ${gsubList}.txt
fi
echo

# Exit
echo "Finished modifying the font tables."
echo
exit 0
