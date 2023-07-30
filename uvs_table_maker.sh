#!/bin/bash

# UVS table maker
#
# Copyright (c) 2023 omonomo

# 異体字に対応するため、フォント生成時に失われたUVS情報を復元させるファイルを作成するプログラム
#
# 生成フォントのGSUBテーブルを利用して、
# glyphナンバーを漢字用フォントの番号から生成フォントの番号に置き換えた
# 新しいcmapテーブル(format_14)を作成する

fromFontName="BIZUDGothic-Regular" # 抽出元フォント名
font_familyname="Cyroit" # 生成フォントファミリー名

cmapList="cmapList"
extList="extList"
gsubList="gsubList"
findUv="9022" # 異体字の先頭文字コード
samplingNum="324" # 取り出すglyphナンバーの数

leaving_tmp_flag="false" # 一時ファイル残す

fonts_directories=". ${HOME}/.fonts /usr/local/share/fonts /usr/share/fonts \
${HOME}/Library/Fonts /Library/Fonts \
/c/Windows/Fonts /cygdrive/c/Windows/Fonts"

echo
echo "- UVS [cmap_format_14] table maker -"
echo

uvs_tablemaker_help()
{
    echo "Usage: uvs_table_maker.sh [options]"
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
            uvs_tablemaker_help
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

toFontName="${font_familyname}-Regular" # 生成フォント名

# フォントがあるかチェック
tmp=""
for i in $fonts_directories
do
    [ -d "${i}" ] && tmp="${tmp} ${i}"
done
fonts_directories=$tmp
fromFontName_ttf=`find ${fonts_directories} -follow -name "${fromFontName}.ttf" | head -n 1`
if [ -z "${fromFontName_ttf}" ]
then
  echo "Error: ${fromFontName} not found" >&2
  exit 1
fi
toFontName_ttf=`find . -name "${toFontName}.ttf" | head -n 1`
if [ -z "${toFontName_ttf}" ]
then
  echo "Error: ${toFontName} not found" >&2
  exit 1
fi

# ttxファイルとtxtファイルを削除
rm -f ${fromFontName}.ttx ${fromFontName}.ttx.bak
rm -f ${toFontName}.ttx ${toFontName}.ttx.bak
rm -f ${cmapList}.txt ${cmapList}.txt.bak
rm -f ${extList}.txt ${extList}.txt.bak
rm -f ${gsubList}.txt ${gsubList}.txt.bak

# ttxファイルを生成
ttx -t cmap "${fromFontName_ttf}"
ttx -t GSUB "${toFontName_ttf}"
fromFontName_ttx=`find ${fonts_directories} -follow -name "${fromFontName}.ttx" | head -n 1`
if [ -n "${fromFontName_ttx}" ] && [ ${fromFontName_ttx} != "./${fromFontName}.ttx" ]
then # 元フォントがカレントディレクトリに無ければ生成したttxファイルを移動
	echo "Move ${fromFontName}.ttx"
	mv ${fromFontName_ttx} ./
fi
echo

# 元のフォントのcmapから異体字セレクタリスト(format_14)を取り出す
echo "Make cmap List"
grep "<cmap_format_14" "${fromFontName}.ttx" >> "${cmapList}.txt"
grep "map uv=" "${fromFontName}.ttx" >> "${cmapList}.txt"
echo "</cmap_format_14>" >> "${cmapList}.txt"

# 取り出したリストから外字のみのリストを作成
echo "Make external char list"
line=`grep "map uv=\"0x${findUv}\"" "${cmapList}.txt" | head -n 1`
temp=${line#*glyph} # glyphナンバーより前を削除
fromNum=${temp%\"*} # glyphナンバーより後を削除
echo "${fromFontName}: 0x${findUv} -> glyph${fromNum}"

for i in `seq 0 ${samplingNum}`
do
	grep "glyph$((fromNum + i))" "${cmapList}.txt" >> "${extList}.txt"
done

# 作成するフォントのGSUBから置換用リストを作成
echo "Make GSUB list"
line=`grep "Substitution in=\"uni${findUv}\"" "${toFontName}.ttx" | head -n 1`
temp=${line#*glyph} # glyphナンバーより前を削除
toNum=${temp%\"*} # glyphナンバーより後を削除
echo "${toFontName}: 0x${findUv} -> glyph${toNum}"

for i in `seq 0 ${samplingNum}`
do
	grep "glyph$((toNum + i))" "${toFontName}.ttx" | head -n 1 >> "${gsubList}.txt"
done

# 異体字セレクタリストのglyphナンバーを置換用リストの物に置き換える
echo "Modify cmap list"
i=1
while read toLine
do
	fromLine=`head -n ${i} "${extList}.txt" | tail -n 1`
	temp=${fromLine#*glyph} # glyphナンバーより前を削除
	fromNum=${temp%\"*} # glyphナンバーより後を削除

	temp=${toLine##*glyph} # glyphナンバーより前を削除
	toNum=${temp%\"*} # glyphナンバーより後を削除

	sed -i.bak -e "s/glyph${fromNum}/glyph${toNum}/g" "${cmapList}.txt"
	i=$((i + 1))
done < "${gsubList}.txt"
echo

# 一時ファイルを削除
echo "Remove temporary files"
  rm -f ${fromFontName}.ttx.bak
  rm -f ${toFontName}.ttx.bak
  rm -f ${cmapList}.txt.bak
  rm -f ${extList}.txt.bak
  rm -f ${gsubList}.txt.bak
if [ "${leaving_tmp_flag}" = "false" ]
then
  rm -f ${fromFontName}.ttx
  rm -f ${toFontName}.ttx
fi
echo

# Exit
echo "Finished making the modified table [cmap_format_14]."
echo
exit 0
