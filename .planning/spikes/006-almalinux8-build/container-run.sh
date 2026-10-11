# usage: run.sh <name> <wait-seconds> <url> [extra -e flags...]
export PATH="$PATH:/mnt/c/Program Files/Docker/Docker/resources/bin"
NAME=$1; WAIT=$2; URL=$3; shift 3
OUT=/mnt/c/Users/User/Documents/Projects/GNUS/GW-linux-webview/.planning/spikes/006-almalinux8-build
docker rm -f spk >/dev/null 2>&1
docker run -d --name spk -e DISPLAY=:0 -e GDK_BACKEND=x11 -e SPIKE_URL=$URL -e SPIKE_LOG=/work/$NAME.json "$@" \
  -v /tmp/.X11-unix:/tmp/.X11-unix -v /mnt/wslg:/mnt/wslg -v /home/braian/spike006:/work \
  -w /work/spike_app gw-spike006 build/linux/x64/debug/bundle/spike_app >/dev/null
sleep $WAIT
WID=$(DISPLAY=:0 xdotool search --name '^spike_app$' 2>/dev/null | tail -1)
echo "window=$WID"
[ -n "$WID" ] && DISPLAY=:0 import -window $WID $OUT/$NAME.png && echo "shot $NAME.png"
sleep 6
docker logs spk > $OUT/$NAME.log 2>&1
grep -E "SPIKE|CRITICAL|WARN|rror" $OUT/$NAME.log | grep -v "Woah" | head -40
[ -f /home/braian/spike006/$NAME.json ] && cp /home/braian/spike006/$NAME.json $OUT/
docker rm -f spk >/dev/null 2>&1
