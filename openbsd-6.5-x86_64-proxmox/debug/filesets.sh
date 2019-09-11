#!/bin/sh
set -e

printf "\nFound OpenBSD file sets:\n"
[[ -f /bsd.sp ]] && printf "[X] bsd\n"
[[ -f /bsd ]] && [[ -f /bsd.mp ]] && printf "[X] bsd\n"
[[ -f /bsd.mp ]] && printf "[X] bsd.mp\n"
[[ -f /bsd ]] && [[ -f /bsd.sp ]] && printf "[X] bsd.mp\n"
[[ -f /bsd.rd ]] && printf "[X] bsd.rd\n"
[[ -f /sbin/dmesg ]] && printf "[X] base65\n"
[[ -f /usr/bin/g++ ]] && printf "[X] comp65\n"
[[ -f /usr/games/worm ]] && printf "[X] game65\n"
[[ -f /usr/share/man/man5/fstab.5 ]] && printf "[X] man65\n"
[[ -f /usr/X11R6/bin/xhost ]] && printf "[X] xbase65\n"
[[ -f /usr/X11R6/lib/X11/fonts/100dpi/courR12.pcf.gz ]] && printf "[X] xfont65\n"
[[ -f /usr/X11R6/bin/Xorg ]] && printf "[X] xserv65\n"
[[ -f /usr/X11R6/bin/x11perfcomp ]] && printf "[X] xshare65\n"
