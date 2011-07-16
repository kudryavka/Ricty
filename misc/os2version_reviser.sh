#!/bin/sh

########################################
# OS/2 Version Reviser
#
# Last modified: os2version_reviser.sh on Sat, 16 Jul 2011.
#
# Author: Yasunori Yusa <lastname at save dot sys.t.u-tokyo.ac.jp>
#
# How to use:
# % sh os2version_reviser.sh filename1.ttf filename2.ttf ...
########################################

# parameters
fontforge_cmd="fontforge"
os2_version="1"

# usage
if [ $# -eq 0 ]
then
    echo "Usage: os2version_reviser.sh <filename.ttf>..."
    exit 0
fi

# make tmp
if [ -w "/tmp" ]
then
    tmpdir=`mktemp -d /tmp/os2version_reviser_tmpdir.XXXXXX` || exit 2
else
    tmpdir=`mktemp -d ./os2version_reviser_tmpdir.XXXXXX`    || exit 2
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
    sed -e "s/^OS2Version: .\+$/OS2Version: ${os2_version}/" \
        ${tmpdir}/tmpsfd.sfd > ${tmpdir}/tmpsfd2.sfd
    mv -f $filename $filename.bak
    $fontforge_cmd -script ${tmpdir}/sfd2ttf.pe 2> /dev/null
done
