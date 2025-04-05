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

source ../assets/func.sh

#------------------------------------------------------------------------------
# Override Build_SheepShaver to patch sysdeps.h for ANSI header issues.
#------------------------------------------------------------------------------
function Build_SheepShaver {
    printf "\e[95m"; echo '
 ____  _                    ____  _
/ ___|| |__   ___  ___ _ __/ ___|| |__   __ ___   _____ _ __
\___ \|  _ \ / _ \/ _ \  _ \___ \|  _ \ / _` \ \ / / _ \  __|
 ___) | | | |  __/  __/ |_) |__) | | | | (_| |\ V /  __/ |
|____/|_| |_|\___|\___| .__/____/|_| |_|\__,_| \_/ \___|_|
                      |_|
'; printf "\e[0m"; sleep 2

    mkdir -p ${SRC_DIR} 2>/dev/null
    cd ${SRC_DIR}
    rm -rf macemu 2>/dev/null
    git clone ${BASILISK_REPO}
    cd ${SRC_DIR}/macemu
    git checkout 33c3419
    cd ${SRC_DIR}/macemu/SheepShaver

    make links
    cd src/Unix

    # Patch sysdeps.h so that the ANSI header check also passes for C++
    if [ -f sysdeps.h ]; then
      sed -i 's/#ifndef __STDC__/#if !defined(__STDC__) \&\& !defined(__cplusplus)/' sysdeps.h
    fi

    NO_CONFIGURE=1 ./autogen.sh &&
    ./configure --enable-sdl-audio \
                --enable-sdl-video \
                --enable-sdl-framework \
                --without-gtk \
                --without-mon \
                --without-esd \
                --enable-addressing=direct,0x10000000

    make -j3
    sudo make install

    modprobe --show sheep_net 2>/dev/null || Build_NetDriver

    echo "no-sighandler" | sudo tee /etc/directfbrc
    grep -q mmap_min_addr /etc/sysctl.conf || \
    echo "vm.mmap_min_addr = 0" | sudo tee -a /etc/sysctl.conf

    rm -rf ${SRC_DIR}
}

#------------------------------------------------------------------------------
# Continue with the normal macos9.sh process
#------------------------------------------------------------------------------
usercheck
updateinfo
MacOS_version 9

sudo apt install -y libdirectfb-dev automake gobjc libudev-dev xa65 build-essential \
                    alsa-oss osspd byacc texi2html flex libreadline-dev libxaw7-dev \
                    texinfo libxaw7-dev libgtk2.0-cil-dev libgtkglext1-dev libpulse-dev \
                    bison libnet1 libnet1-dev libpcap0.8 libpcap0.8-dev libvte-dev \
                    libasound2-dev linux-headers-$(uname -r) build-essential git \
                    libgtk2.0-dev x11proto-xf86dga-dev libesd0-dev libxxf86dga-dev \
                    libxxf86dga1 libsdl1.2-dev 

[ $? -ne 0 ] && net_error "Mac OS 9 apt packages"

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

# SDL2 and SheepShaver build steps
[ -f $SDL2_FILE ] || Build_SDL2
[ -f $SHEEPSHAVER_FILE ] || Build_SheepShaver

echo "* Mac OS 9 installation complete"
sleep 2
