#!/bin/bash
# --------------------------------------------------------
# MacintoshDebian
# --------------------------------------------------------
# This project allows running full-screen versions of
# Apple's Mac OS 9 with audio, active online connection,
# and modem emulation under a CLI-only Debian 32bit (i386)
# system.
# --------------------------------------------------------
# Author: Jaroslaw Mazurkiewicz  /  jaromaz
# www: https://jm.iq.pl  e-mail: jm at iq.pl
# --------------------------------------------------------

printf "\e[92m"; echo '
 __  __             ___  ____     ___  
|  \/  | __ _  ___ / _ \/ ___|   / _ \ 
| |\/| |/ _` |/ __| | | \___ \  | (_) |
| |  | | (_| | (__| |_| |___) |  \__, |
|_|  |_|\__,_|\___|\___/|____/     /_/ 
'; printf "\e[0m"; sleep 2

wget https://github.com/Korkman/macemu-appimage-builder/releases/download/continuous/SheepShaver-i386.AppImage
chmod +x SheepShaver-i386.AppImage
./SheepShaver-i386.AppImage --appimage-extract

# Mac OS 9 configuration
echo "
rom    ${MACOS_DIR}/newworld86.rom
disk   ${MACOS_DIR}/hdd.dsk
frameskip 2
ramsize 134217728
ether slirp
nosound false
nocdrom false
nogui false
jit false
mousewheelmode 1
mousewheellines 3
dsp /dev/dsp
mixer
ignoresegv true
idlewait true
seriala /dev/tnt1
serialb /dev/null
extfs /home/pi/Downloads
screen win/800/600
# screen dga/800/600
# screen win/640/480
" > ${MACOS_CONFIG}

# ROM & System setup
cd ${MACOS_DIR}
wget --no-check-certificate ${ROM}
[ $? -ne 0 ] && net_error "Mac OS 9 ROM file"
unzip newworld86.rom.zip 2>/dev/null
wget -O ${MACOS_DIR}/hdd.dsk.gz ${HDD_IMAGE}
[ $? -ne 0 ] && net_error "Mac OS 9 HDD image"
echo "* Decompressing the hard drive image - please wait"
gzip -d hdd.dsk.gz

echo "* Mac OS 9 installation complete"
sleep 2
