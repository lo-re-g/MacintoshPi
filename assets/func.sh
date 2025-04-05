#!/bin/bash
# --------------------------------------------------------
# MacintoshPi (Adapted for x86 Debian)
# --------------------------------------------------------
# Functions for setting up and building SheepShaver/BasiliskII
# --------------------------------------------------------

VERSION="1.4.1"
BASE_DIR="/usr/share/macintoshpi"
CONF_DIR="/etc/macintoshpi"
WAV_DIR="${BASE_DIR}/sounds"
SRC_DIR="${BASE_DIR}/src"
BASILISK_REPO="https://github.com/kanjitalk755/macemu"
SHEEPSHAVER_REPO=${BASILISK_REPO}
SDL2_SOURCE="https://www.libsdl.org/release/SDL2-2.0.7.tar.gz"
VICE_SOURCE="https://downloads.sourceforge.net/project/vice-emu/releases/vice-3.4.tar.gz"
BASILISK_FILE="/usr/local/bin/BasiliskII"
SHEEPSHAVER_FILE="/usr/local/bin/SheepShaver"
SDL2_FILE="/usr/local/lib/libSDL2-2.0.so.0.7.0"
HDD_IMAGES="https://homer-retro.space/appfiles"
ASOFT="${HDD_IMAGES}/as/asoft.tar.gz"
ROM4OS[7]="https://github.com/macmade/Macintosh-ROMs/raw/18e1d0a9756f8ae3b9c005a976d292d7cf0a6f14/Performa-630.ROM"
ROM4OS[8]="https://github.com/macmade/Macintosh-ROMs/raw/main/Quadra-650.ROM"
ROM4OS[9]="https://smb4.s3.us-west-2.amazonaws.com/sheepshaver/apple_roms/newworld86.rom.zip"

function usercheck {
  if [ "$EUID" -eq 0 ]; then
    echo "Please do not run this script as root."
    exit 1
  fi
}

function updateinfo {
  parent=$(cat /proc/$PPID/comm)
  if [ "$parent" != "build_all.sh" ]; then
    echo -e "\n* WARNING:\nYou should update and reboot your system before running this script."
    echo "Press 'y' to update and reboot now, or wait 30 seconds to skip."
    read -t 30 -n 1 -s updinfo
    if [ "$updinfo" = "y" ]; then
      sudo apt update && sudo apt upgrade -y && sudo reboot
      exit
    fi
  fi
}

function mtimer {
  for i in {10..1}; do printf "$i ... "; sleep 1; done; echo
}

function installinfo {
  echo "* INFO: The build process may take up to two hours."
  mtimer
}

function net_error {
  echo -e "\n***********"
  echo "Error downloading: $1"
  echo "Check your internet connection or report here:"
  echo "https://github.com/jaromaz/MacintoshPi/issues/new"
  echo "***********"
  exit 1
}

function Base_dir {
  [ -d "$BASE_DIR" ] || sudo mkdir -p "$BASE_DIR"
}

function Src_dir {
  [ -d "$SRC_DIR" ] || sudo mkdir -p "$SRC_DIR"
}

function Build_NetDriver {
  echo "* Note: Network driver (sheep_net) not applicable on x86. Skipping..."
}

function Build_SheepShaver {
  echo "* Building SheepShaver..."
  mkdir -p "$SRC_DIR"
  cd "$SRC_DIR"
  rm -rf macemu
  git clone "$SHEEPSHAVER_REPO"
  cd macemu
  git checkout 33c3419
  cd SheepShaver
  make links
  cd src/Unix

  NO_CONFIGURE=1 ./autogen.sh
  ./configure --enable-sdl-audio \
              --enable-sdl-video \
              --without-gtk \
              --without-esd \
              --enable-addressing=direct,0x10000000
  make -j$(nproc)
  sudo make install

  echo "no-sighandler" | sudo tee /etc/directfbrc
  grep -q mmap_min_addr /etc/sysctl.conf || echo "vm.mmap_min_addr = 0" | sudo tee -a /etc/sysctl.conf
}

function Build_BasiliskII {
  echo "* Building BasiliskII..."
  mkdir -p "$SRC_DIR"
  cd "$SRC_DIR"
  rm -rf macemu
  git clone "$BASILISK_REPO"
  cd macemu
  git checkout 33c3419
  cd BasiliskII/src/Unix

  NO_CONFIGURE=1 ./autogen.sh
  ./configure --enable-sdl-audio \
              --enable-sdl-video \
              --without-gtk \
              --without-esd \
              --disable-nls
  make -j$(nproc)
  sudo make install
}

function Build_SDL2 {
  echo "* Building SDL2 from source..."
  sudo apt install -y automake gobjc libudev-dev xa65 build-essential byacc texi2html flex \
                      libreadline-dev libxaw7-dev texinfo libgtk2.0-cil-dev libgtkglext1-dev \
                      libpulse-dev bison libnet1 libnet1-dev libpcap0.8 libpcap0.8-dev \
                      libvte-dev libasound2-dev linux-headers-$(uname -r) unzip wget gzip
  [ $? -ne 0 ] && net_error "SDL2 apt packages"

  Base_dir
  mkdir -p "$SRC_DIR"

  wget "$SDL2_SOURCE" -O - | tar -xz -C "$SRC_DIR"
  [ $? -ne 0 ] && net_error "SDL2 sources"

  cd "$SRC_DIR/SDL2-2.0.7"
  ./configure --disable-video-opengl \
              --disable-video-mir \
              --disable-video-wayland \
              --enable-video-x11 \
              --enable-alsa \
              --enable-audio
  make -j$(nproc)
  sudo make install
}

function Launcher {
  if ! [ -d "$CONF_DIR" ]; then
    mkdir -p "$SRC_DIR"
    cd ../launcher || exit
    sudo mkdir -p "$CONF_DIR"
    sudo cp -r config/* "$CONF_DIR"
    sudo cp mac /usr/bin

    wget -O "$SRC_DIR/chimes.zip" "$HDD_IMAGES/chimes.zip"
    unzip -d "$SRC_DIR" "$SRC_DIR/chimes.zip" || net_error "Chimes wav files"

    sudo mkdir -p "$WAV_DIR"
    for i in os7-342 os7-384 os7-480 os7-600 os8-480 os8-600 os9-480 os9-600 os9-768; do
      sudo mkdir -p "$CONF_DIR/$i$WAV_DIR"
    done

    # Copy WAVs
    sudo cp "$SRC_DIR/chimes/"*.wav "$WAV_DIR/" 2>/dev/null
    rm -rf "$SRC_DIR"
  fi
}

function MacOS_version {
  Base_dir
  VER=$1
  MACOS_DIR="${BASE_DIR}/macos${VER}"
  HDD_IMAGE="${HDD_IMAGES}/${VER}/hdd.dsk.gz"
  MACOS_CONFIG="${MACOS_DIR}/macos${VER}.cfg"
  ROM="${ROM4OS[$1]}"
  rm -rf "$MACOS_DIR"
  mkdir -p "$MACOS_DIR"
  Launcher
}

function logo {
  clear
  echo -e "\e[96m"
  cat <<EOF
 __  __            _       _            _     
|  \/  | __ _  ___(_)_ __ | |_ ___  ___| |__  
| |\/| |/ _\` |/ __| | '_ \| __/ _ \/ __| '_ \ 
| |  | | (_| | (__| | | | | ||  __/\__ \ | | |
|_|  |_|\__,_|\___|_|_| |_|\__\___||___/_| |_|  v.${VERSION}
EOF
  echo -e "\e[0m"
}

function Asoft {
  if ! [ -d "${BASE_DIR}/asoft" ]; then
    wget -c "$ASOFT" -O - | tar -xz -C "$BASE_DIR"
    [ $? -ne 0 ] && net_error "asoft"
  fi
}
