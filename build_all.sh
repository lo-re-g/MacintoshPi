#!/bin/bash
# --------------------------------------------------------
# MacintoshPi (Adapted for x86 Debian) / 2025
# --------------------------------------------------------
# Installs and configures full-screen versions of
# Mac OS 7, 8, and 9 with audio, network, and modem
# emulation — now adapted for x86 Debian environments.
# --------------------------------------------------------
# Original Author: Jaroslaw Mazurkiewicz / jaromaz
# Adapted by: [Your Name]
# --------------------------------------------------------

# Load shared functions
source assets/func.sh

# Initial setup
usercheck
logo
updateinfo
installinfo

# Apps to install
APPS=(macos7 macos8 macos9 vice cdemu vmodem syncterm)

for APP in "${APPS[@]}"; do
    if [ -d "$APP" ] && [ -x "$APP/${APP}.sh" ]; then
        echo "* Installing $APP..."
        ( cd "$APP" && "./${APP}.sh" )
    else
        echo "⚠️  Skipping $APP: script or directory not found."
    fi
done

echo -e "\n✅ All components installed."
