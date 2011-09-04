#!/bin/sh

#
# OS/2 Version Reviser
#
# Author: Yasunori Yusa <lastname at save dot sys.t.u-tokyo.ac.jp>
#
# This script is for revising OS/2 Version of Ricty.
# If the spaces between fullwidth charcters are unusually large,
# you can use this script and revise it.
#
# How to use:
# % sh os2version_reviser.sh Ricty-*.ttf RictyDiscord-*.ttf
#

# parameters
fontforge_cmd="fontforge"
os2_version="1"

# usage
if [ $# -eq 0 ]
then
    echo "Usage: os2version_reviser.sh filename.ttf ..."
    exit 0
fi

# make tmp
if [ -w "/tmp" ]
then
    tmpdir=`mktemp -d /tmp/os2version_reviser_tmpdir.XXXXXX`
else
    tmpdir=`mktemp -d ./os2version_reviser_tmpdir.XXXXXX`
fi

# remove tmp by trapping
trap "if [ -d $tmpdir ]; then rm -rf $tmpdir; fi" EXIT HUP INT QUIT

# args loop
for filename in $@
do
    # generate scripts
    cat > ${tmpdir}/ttf2sfd.pe << _EOT_
#!$fontforge_cmd -script
Open("${filename}")
Save("${tmpdir}/tmpsfd.sfd")
_EOT_
    cat > ${tmpdir}/sfd2ttf.pe << _EOT_
#!$fontforge_cmd -script
Open("${tmpdir}/tmpsfd2.sfd")
Generate("${filename}", "", 0x84)
_EOT_
    # convert file
    $fontforge_cmd -script ${tmpdir}/ttf2sfd.pe 2> /dev/null
    sed -e "s/^OS2Version: .*$/OS2Version: ${os2_version}/" \
        ${tmpdir}/tmpsfd.sfd > ${tmpdir}/tmpsfd2.sfd
    mv -f $filename $filename.bak
    $fontforge_cmd -script ${tmpdir}/sfd2ttf.pe 2> /dev/null
done
