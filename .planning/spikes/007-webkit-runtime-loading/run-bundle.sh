# usage: run-bundle.sh <name> <wait-seconds> <host|docker-image> [extra docker -e flags...]
# Runs the EL8-built release bundle, screenshots the window via the WSLg X server, saves the log.
export PATH="$PATH:/mnt/c/Program Files/Docker/Docker/resources/bin"
NAME=$1; WAIT=$2; TARGET=$3; shift 3
OUT=/mnt/c/Users/User/Documents/Projects/GNUS/GW-linux-webview/.planning/spikes/007-webkit-runtime-loading
B=/home/braian/spike007/spike_app/build/linux/x64/release/bundle
pkill -f "$B/spike_app" 2>/dev/null; docker rm -f spk >/dev/null 2>&1
if [ "$TARGET" = host ]; then
  { echo "== ldd (webkit/soup/jsc/not found)"; ldd $B/spike_app | grep -Ei 'webkit|soup|javascriptcore|not found' || echo none; } > $OUT/$NAME.log
  (cd $B && DISPLAY=:0 GDK_BACKEND=x11 "$@" ./spike_app >> $OUT/$NAME.log 2>&1 &)
else
  docker run --rm $TARGET bash -c 'cat /etc/os-release | grep PRETTY' > $OUT/$NAME.log
  docker run --rm -v $B:/b $TARGET bash -c 'echo "== ldd (webkit/soup/jsc/not found)"; ldd /b/spike_app | grep -Ei "webkit|soup|javascriptcore|not found" || echo none; echo "== webkit libs present"; ls /usr/lib64 /usr/lib/x86_64-linux-gnu 2>/dev/null | grep -E "^libwebkit2gtk|^libsoup-[23]" || echo none' >> $OUT/$NAME.log
  docker run -d --name spk -e DISPLAY=:0 -e GDK_BACKEND=x11 "$@" \
    -v /tmp/.X11-unix:/tmp/.X11-unix -v /mnt/wslg:/mnt/wslg -v $B:/b -w /b $TARGET bash -c "${PRE:-} exec ./spike_app" >/dev/null
fi
sleep $WAIT
WID=$(DISPLAY=:0 xdotool search --name '^spike_app$' 2>/dev/null | tail -1)
echo "window=$WID"
[ -n "$WID" ] && DISPLAY=:0 import -window $WID $OUT/$NAME.png && echo "shot $NAME.png"
[ "$TARGET" = host ] || docker logs spk >> $OUT/$NAME.log 2>&1
pkill -f "$B/spike_app" 2>/dev/null; docker rm -f spk >/dev/null 2>&1
grep -Ev "Woah|^$" $OUT/$NAME.log | head -40
