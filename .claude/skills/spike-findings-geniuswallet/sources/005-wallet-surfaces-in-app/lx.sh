#!/bin/bash
# lx.sh click X Y | type TEXT | key KEY | scroll X Y BTN N | shot NAME | size W H  (coords relative to the app window)
export DISPLAY=:0
WID=$(cat /home/braian/gw005/run/win.id)
OUT=/mnt/c/Users/User/Documents/Projects/GNUS/GW-linux-webview/.planning/spikes/005-wallet-surfaces-in-app
TMP=/mnt/c/Users/User/AppData/Local/Temp/claude/C--Users-User-Documents-Projects-GNUS-GeniusWallet/f900e545-5b78-4fbc-994b-02191fd38bc0/scratchpad/spike/005/shots
mkdir -p $OUT $TMP
case "$1" in
  click) xdotool windowactivate --sync $WID 2>/dev/null; xdotool mousemove --window $WID $2 $3 click 1;;
  move) xdotool mousemove --window $WID $2 $3;;
  type) xdotool windowactivate --sync $WID 2>/dev/null; xdotool type --delay 40 "$2";;
  key) xdotool windowactivate --sync $WID 2>/dev/null; xdotool key $2;;
  scroll) xdotool mousemove --window $WID $2 $3; for i in $(seq 1 ${5:-3}); do xdotool click $4; done;;
  shot) import -window $WID "$OUT/$2.png" && echo "$OUT/$2.png";;
  tmp) import -window $WID "$TMP/$2.png" && echo "$TMP/$2.png";;
  size) xdotool windowsize $WID $2 $3;;
  log) grep -v Woah /home/braian/gw005/run/app.log | tail -${2:-20};;
esac
