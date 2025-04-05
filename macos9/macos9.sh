#!/bin/bash
# --------------------------------------------------------
# MacintoshPi (adapted for x86 Debian)
# --------------------------------------------------------
# This script installs and configures SheepShaver to run
# Mac OS 9 on x86 Debian systems, including automatic
# build of dependencies, SDL2, and SheepShaver itself.
# --------------------------------------------------------

printf "\e[92m"; echo '
 __  __             ___  ____     ___  
|  \/  | __ _  ___ / _ \/ ___|   / _ \ 
| |\/| |/ _` |/ __| | | \___ \  | (_) |
| |  | | (_| | (__| |_| |___) |  \__, |
|_|  |_|\__,_|\___|\___/|____/     /_/ 

'; printf "\e[0m"; sleep 2

# --- Functions (or source external script if available) ---
if [ -f "../assets/func.sh" ]; then
  source ../assets/func.sh
else
  echo "* Warning: func.sh not found. Skipping extra functions."
  function usercheck() { :; }
  function updateinfo() { :; }
  function MacOS_version() { :; }
  function net_error() { echo "Network error: $1"; exit 1; }
  function Build_SDL2() { echo "Placeholder: Build SDL2"; }
  function Build_SheepShaver() { echo "Placeholder: Build SheepShaver"; }
fi

usercheck
updateinfo
MacOS_version 9

# --- Install dependencies ---
sudo apt update
sudo apt install -y libdirectfb-dev automake gobjc libudev-dev xa65 build-essential \
					alsa-oss osspd byacc texi2html flex libreadline-dev libxaw7-dev texinfo \
					libgtk2.0-cil-dev libgtkglext1-dev libpulse-dev bison libnet1 libnet1-dev \
					libpcap0.8 libpcap0.8-dev libvte-dev libasound2-dev libgtk2.0-dev \
					x11proto-xf86dga-dev libesd0-dev libxxf86dga-dev libxxf86dga1 libsdl1.2-dev \
					linux-headers-$(uname -r) git unzip wget gzip

[ $? -ne 0 ] && net_error "Mac OS 9 apt packages"

# --- Paths ---
MACOS_DIR="$HOME/MacOS9"
MACOS_CONFIG="$MACOS_DIR/SheepShaver_prefs"
ROM="https://example.com/newworld86.rom.zip"  # <-- replace with actual ROM URL
HDD_IMAGE="https://example.com/hdd.dsk.gz"    # <-- replace with actual HDD image URL
SDL2_FILE="$MACOS_DIR/SDL2_built_flag"
SHEEPSHAVER_FILE="$MACOS_DIR/SheepShaver_built_flag"

mkdir -p "$MACOS_DIR"

# --- Create SheepShaver config ---
cat <<EOF > "$MACOS_CONFIG"
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
seriala /dev/null
serialb /dev/null
extfs ${HOME}/Downloads
screen win/800/600
# screen dga/800/600
EOF

# --- Download ROM and Disk Image ---
cd "$MACOS_DIR"
wget --no-check-certificate "$ROM" -O newworld86.rom.zip
[ $? -ne 0 ] && net_error "Mac OS 9 ROM file"
unzip newworld86.rom.zip
wget -O hdd.dsk.gz "$HDD_IMAGE"
[ $? -ne 0 ] && net_error "Mac OS 9 HDD image"
echo "* Decompressing the hard drive image - please wait"
gzip -d hdd.dsk.gz

# --- Build SDL2 if not found ---
[ -f "$SDL2_FILE" ] || Build_SDL2

# --- Build SheepShaver if not found ---
[ -f "$SHEEPSHAVER_FILE" ] || Build_SheepShaver

echo "* Mac OS 9 installation complete"
sleep 2
