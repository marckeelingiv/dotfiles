#!/bin/bash

VIDEO="$HOME/.config/omarchy/themes/deep-ocean/backgrounds/deep-ocean.mp4"

if [[ "$1" == "deep-ocean" ]]; then
  pkill -x swaybg 2>/dev/null
  pkill -x mpvpaper 2>/dev/null
  setsid uwsm-app -- mpvpaper -o "no-audio loop" '*' "$VIDEO" >/dev/null 2>&1 &
else
  pkill -x mpvpaper 2>/dev/null
fi
