#!/bin/sh

########################################
# Ricty Generator 3.0.0
#
# Last modified: ricty_generator.sh on Fri, 17 May 2011.
#
# Copyright (c) Yasunori Yusa
#
# This script is for generating ``Ricty'' font from Inconsolata and Migu 1M.
# It requires 2-5 minutes to generate Ricty. Owing to SIL Open Font License
# Version 1.1 section 5, it is PROHIBITED to distribute the generated font.
# This script supports following versions of inputting fonts.
# * Inconsolata Version 001.010
# * Migu 1M     Version 20110418
#                       20110514
#
# How to use:
# 1. Install FontForge
#    Debian/Ubuntu: # apt-get install fontforge
#    Fedora:        # yum install fontforge
#    Other Linux:   Get from http://fontforge.sourceforge.net/
# 2. Install Inconsolata
#    Debian/Ubuntu: # apt-get install ttf-inconsolata
#    Other Linux:   Get from http://levien.com/type/myfonts/inconsolata.html
# 3. Install Migu 1M
#                   Get from http://mix-mplus-ipa.sourceforge.jp/
# 4. Run this script
#    % sh ricty_generator.sh \
#      /.../Inconsolata.otf /.../Migu-1M-regular.ttf /.../Migu-1M-bold.ttf
# 5. Install Ricty
#    % cp Ricty-{Regular,Bold}.ttf ~/.fonts/
#    % fc-cache -vf
########################################

# check argc
if [ $# -ne 3 ]
then
    echo "Usage: sh ricty_generator.sh" \
	"Inconsolata.otf Migu-1M-regular.ttf Migu-1M-bold.ttf"
    exit 0
fi

# get argv
input_inconsolata=$1
input_migu1m_regular=$2
input_migu1m_bold=$3

# check file existance
if [ ! -f $input_inconsolata ]
then
    echo "Error: $input_inconsolata not found"
    exit 1
fi
if [ ! -f $input_migu1m_regular ]
then
    echo "Error: $input_migu1m_regular not found"
    exit 1
fi
if [ ! -f $input_migu1m_bold ]
then
    echo "Error: $input_migu1m_bold not found"
    exit 1
fi

# check filename
if [ `basename $input_inconsolata` != "Inconsolata.otf" ]
then
    echo "Warning: $input_inconsolata is really Inconsolata?"
fi
if [ `basename $input_migu1m_regular` != "Migu-1M-regular.ttf" ]
then
    echo "Warning: $input_migu1m_regular is really Migu 1M Regular?"
fi
if [ `basename $input_migu1m_bold` != "Migu-1M-bold.ttf" ]
then
    echo "Warning: $input_migu1m_bold is really Migu 1M Bold?"
fi

# parameters
ricty_version="3.0.0"
modified_inconsolata_generator="modified_inconsolata_generator.pe"
modified_inconsolata_regular="Modified-Inconsolata-Regular.sfd"
modified_inconsolata_bold="Modified-Inconsolata-Bold.sfd"
modified_migu1m_generator="modified_migu1m_generator.pe"
modified_migu1m_regular="Modified-Migu-1M-regular.sfd"
modified_migu1m_bold="Modified-Migu-1M-bold.sfd"
ricty_generator="ricty_generator.pe"
tmpdir=`mktemp -d ricty_generator_workspace.XXXXXX`

########################################
# print message
########################################

cat << _EOF_
Ricty Generator $ricty_version

Copyright (c) Yasunori Yusa

This script is for generating \`\`Ricty'' font from Inconsolata and Migu 1M.
It requires 2-5 minutes to generate Ricty. Owing to SIL Open Font License
Version 1.1 section 5, it is PROHIBITED to distribute the generated font.

_EOF_

########################################
# generate modified Inconsolata
########################################

echo "Generate modified Inconsolata"

# generate script
cat > $tmpdir/$modified_inconsolata_generator << _EOF_
# open
Open("$input_inconsolata")
# scale
ScaleToEm(860, 140)
# remove ambiguous
Select(0u00a2); Clear() # cent
Select(0u00a3); Clear() # pound
Select(0u00a4); Clear() # currency
Select(0u00a5); Clear() # yen
Select(0u00a7); Clear() # section
Select(0u00a8); Clear() # dieresis
Select(0u00ac); Clear() # not
Select(0u00ad); Clear() # soft hyphen
Select(0u00b0); Clear() # degree
Select(0u00b1); Clear() # plus-minus
Select(0u00b4); Clear() # acute
Select(0u00b6); Clear() # pilcrow
Select(0u00d7); Clear() # multiply
Select(0u00f7); Clear() # divide
Select(0u2018); Clear() # left '
Select(0u2019); Clear() # right '
Select(0u201c); Clear() # left "
Select(0u201d); Clear() # right "
Select(0u2020); Clear() # dagger
Select(0u2021); Clear() # double dagger
Select(0u2026); Clear() # ...
Select(0u2122); Clear() # TM
Select(0u2191); Clear() # uparrow
Select(0u2193); Clear() # downarrow
Select(0u2212); Clear() # minus
Select(0u2423); Clear() # open box
# save regular
Save("$tmpdir/$modified_inconsolata_regular")
# bold-face regular
Print("While bold-facing, wait a bit, a bit...")
SelectWorthOutputting()
ExpandStroke(30, 0, 0, 0, 1)
RemoveOverlap()
RoundToInt()
Select(0u003e); Copy()           # >
Select(0u003c); Paste(); HFlip() # <
# save bold
Save("$tmpdir/$modified_inconsolata_bold")
_EOF_

# generate modified Inconsolata
fontforge -script $tmpdir/$modified_inconsolata_generator

########################################
# generate modified Migu
########################################

# generate script
cat > $tmpdir/$modified_migu1m_generator << _EOF_
# parameters
input_list  = ["$input_migu1m_regular", "$input_migu1m_bold"]
output_list = ["$modified_migu1m_regular", "$modified_migu1m_bold"]
# regular and bold loop
i = 0; while (i < SizeOf(input_list))
    Open(input_list[i])
    Print("While scaling and moving, wait a little...")
    SelectWorthOutputting()
    SetWidth(-1, 1); Scale(91, 91, 0, 0); SetWidth(110, 2); SetWidth(1, 1)
    Move(23, 0); SetWidth(-23, 1)
    RemoveOverlap(); RoundToInt()
    Save("$tmpdir/"+output_list[i])
i += 1; endloop
_EOF_

# generate modified Migu
fontforge -script $tmpdir/$modified_migu1m_generator

########################################
# generate Ricty
########################################

# generate script
cat > $tmpdir/$ricty_generator << _EOF_
# parameters
inconsolata_list = ["$tmpdir/$modified_inconsolata_regular", \
                    "$tmpdir/$modified_inconsolata_bold"]
migu1m_list      = ["$tmpdir/$modified_migu1m_regular", \
                    "$tmpdir/$modified_migu1m_bold"]
fontfamily       = "Ricty"
fontstyle_list   = ["Regular", "Bold"]
fontweight_list  = [400,       700]
copyright        = "Copyright (c) 2011 Yasunori Yusa\n" \
                 + "Copyright (c) 2006-2011 Raph Levien\n" \
                 + "Copyright (c) 2006-2011 itouhiro\n" \
                 + "Copyright (c) 2002-2011 M+ FONTS PROJECT\n" \
                 + "Copyright (c) 2003-2011 " \
                 + "Information-technology Promotion Agency, Japan (IPA)\n" \
                 + "Licenses:\n" \
                 + "SIL Open Font License Version 1.1 " \
                 + "(http://scripts.sil.org/OFL)\n" \
                 + "M+ FONTS LICENSE " \
                 + "(http://mplus-fonts.sourceforge.jp/mplus-outline-fonts/)\n" \
                 + "IPA Font License Agreement v1.0 " \
                 + "(http://ipafont.ipa.go.jp/ipa_font_license_v1.html)"
version          = "$ricty_version"
# regular and bold loop
i = 0; while (i < SizeOf(fontstyle_list))
    # new file
    New()
    # set encoding to Unicode-bmp
    Reencode("unicode")
    # set configs
    SetFontNames(fontfamily+"-"+fontstyle_list[i], \
                 fontfamily, fontfamily+" "+fontstyle_list[i], \
                 fontstyle_list[i], copyright, version)
    ScaleToEm(860, 140)
    SetOS2Value("Weight", fontweight_list[i]) # Book or Bold
    SetOS2Value("Width",           5) # Medium
    SetOS2Value("FSType",          0)
    SetOS2Value("VendorID",   "PfEd")
    SetOS2Value("IBMFamily",    2057) # SS Typewriter Gothic
    SetOS2Value("WinAscent",     800)
    SetOS2Value("WinDescent",    215)
    SetOS2Value("TypoAscent",    860)
    SetOS2Value("TypoDescent",  -140)
    SetOS2Value("TypoLineGap",     0)
    SetOS2Value("HHeadAscent",   800)
    SetOS2Value("HHeadDescent", -215)
    SetOS2Value("HHeadLineGap",    0)
    SetOS2Value("WinAscentIsOffset",    0)
    SetOS2Value("WinDescentIsOffset",   0)
    SetOS2Value("TypoAscentIsOffset",   0)
    SetOS2Value("TypoDescentIsOffset",  0)
    SetOS2Value("HHeadAscentIsOffset",  0)
    SetOS2Value("HHeadDescentIsOffset", 0)
    SetPanose(3, 9) # Monospaced
    # merge fonts
    Print("While merging, wait a little more...")
    MergeFonts(inconsolata_list[i])
    MergeFonts(migu1m_list[i])
    # edit zenkaku space (from ballot box and heavy greek cross)
    Select(0u2610); Copy(); Select(0u3000); Paste()
    Select(0u271a); Copy(); Select(0u3000); PasteInto(); OverlapIntersect()
    # edit zenkaku comma and period
    Select(0uff0c); Scale(150, 150, 100, 0); SetWidth(1000)
    Select(0uff0e); Scale(150, 150, 100, 0); SetWidth(1000)
    # edit zenkaku colon and semicolon
    Select(0uff0c); Copy(); Select(0uff1b); Paste()
    Select(0uff0e); Copy(); Select(0uff1b); PasteWithOffset(0, 400)
    CenterInWidth()
    Select(0uff1a); Paste(); PasteWithOffset(0, 400)
    CenterInWidth()
    # edit en dash
    Select(0u2013); Copy()
    PasteWithOffset(200, 0); PasteWithOffset(-200, 0); OverlapIntersect()
    # edit em dash and horizontal bar
    Select(0u2014); Copy()
    PasteWithOffset(620, 0); PasteWithOffset(-620, 0)
    Select(0u2010); Copy()
    Select(0u2014); PasteInto()
    OverlapIntersect()
    Copy(); Select(0u2015); Paste()
    # post proccess
    SelectWorthOutputting(); RemoveOverlap(); RoundToInt()
    # generate
    Generate(fontfamily+"-"+fontstyle_list[i]+".ttf", "", 0x84)
i += 1; endloop
_EOF_

# generate Ricty
fontforge -script $tmpdir/$ricty_generator

########################################
# post process
########################################

# remove tmp
rm -rf $tmpdir

# print
echo "Succeeded to generate Ricty!"
