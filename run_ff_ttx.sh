#!/bin/bash

# FontForge and TTX runner
#
# Copyright (c) 2023 omonomo


font_familyname="Cyroit"
font_familyname_suffix0="SP"
font_familyname_suffix1="HB"
build_fonts_dir="build"

forge_ttx_help()
{
    echo "Usage: run_ff_ttx.sh [options]"
    echo ""
    echo "Option:"
    echo "  -h  Display this information"
    echo "  -d  Draft mode (skip time-consuming processes)"
    echo "  -de Draft mode (add Nerd fonts)"
    echo "  -e  Add Nerd fonts"
    echo "  -o  Also generate oblique style"
    echo "  -eo Also generate oblique style (add Nerd fonts)"
    echo "  -F  Complete Mode (generate finished fonts)"
}

# フォント作成
if [ $# -eq 0 ]
then
  echo "Normal Mode"
  rm -f ${font_familyname}*.ttf
  sh font_generator.sh -N "${font_familyname}" auto
elif [ "$1" = "-d" ]
then
  echo "Draft Mode"
  rm -f ${font_familyname}*.ttf
  sh font_generator.sh -l -d -N "${font_familyname}" auto
  exit 0 # 下書きモードの場合テーブルを編集しない
elif [ "$1" = "-de" ]
then
  echo "Draft Mode (add Nerd fonts)"
  rm -f ${font_familyname}*.ttf
  sh font_generator.sh -l -d -e -N "${font_familyname}" auto
  exit 0 # 下書きモードの場合テーブルを編集しない
elif [ "$1" = "-e" ]
then
  echo "Normal Mode (add Nerd fonts)"
  rm -f ${font_familyname}*.ttf
  sh font_generator.sh -e -N "${font_familyname}" auto
elif [ "$1" = "-o" ]
then
  echo "Normal Mode (also generate obliqe style)"
  rm -f ${font_familyname}*.ttf
  sh font_generator.sh -o -N "${font_familyname}" auto
elif [ "$1" = "-eo" ]
then
  echo "Normal Mode (also generate oblique style, Add Nerd fonts)"
  rm -f ${font_familyname}*.ttf
  sh font_generator.sh -e -o -N "${font_familyname}" auto
elif [ "$1" = "-F" ]
then
  echo "Complete Mode (generate finished fonts)"
  rm -f ${font_familyname}*.ttf
  sh font_generator.sh -z -o -e -N "${font_familyname}" auto
  if [ -n "${font_familyname_suffix0}" ]
  then
    sh font_generator.sh -o -e -N "${font_familyname}" -n "${font_familyname_suffix0}" auto
  fi
  if [ -n "${font_familyname_suffix1}" ]
  then
    sh font_generator.sh -Z -z -u -b -o -e -N "${font_familyname}" -n "${font_familyname_suffix1}" auto
  fi
elif [ "$1" = "-h" ]
then
  forge_ttx_help
  exit 0
else
  echo "illegal option."
  exit 1
fi

# cmap テーブル加工用ファイルの作成
if [ "$1" = "-F" ]
then
  sh uvs_table_maker.sh -N "${font_familyname}"
else
  sh uvs_table_maker.sh -l -N "${font_familyname}"
fi
if [ $? -eq 1 ]
then
 exit 1
fi
# テーブル加工
if [ "$1" = "-F" ]
then
  sh table_modificator.sh -N "${font_familyname}"
else
  sh table_modificator.sh -l -N "${font_familyname}"
fi
if [ $? -eq 1 ]
then
 exit 1
fi
# 完成したフォントの移動
if [ "$1" = "-F" ]
then
  echo "Move finished fonts"
  mkdir -p "${build_fonts_dir}"
  mv -f ${font_familyname}*.ttf "${build_fonts_dir}/."
  echo
fi
if [ $? -eq 1 ]
then
 exit 1
fi

# Exit
echo "Succeeded in generating custom fonts!"
echo
exit 0
