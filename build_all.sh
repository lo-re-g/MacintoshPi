#!/bin/bash
# --------------------------------------------------------
# MacintoshDebian / 2022
# --------------------------------------------------------
# This project allows running full-screen versions of
# Apple's Mac OS 7, 8 and 9 with audio, active online
# connection, and modem emulation under a CLI-only
# Debian 32bit (i386) system.
# --------------------------------------------------------
# Author: Jaroslaw Mazurkiewicz  /  jaromaz
# www: https://jm.iq.pl  e-mail: jm at iq.pl
# --------------------------------------------------------
source assets/func.sh
usercheck
logo
updateinfo
installinfo
for APP in macos7 macos8 macos9 vice cdemu vmodem syncterm; do
    ( cd ${APP} && ./${APP}.sh )
done
echo '** all done'
