#!/bin/bash
# Fresh test profile: wipes ~/.local/share/GeniusWallet and keyrings, then runs the
# spike bundle under dbus-run-session with an unlocked throwaway gnome-keyring.
# usage: run.sh [VAR=value ...]   extra env for the app (e.g. GW_SPIKE_CHECKOUT_URL=...)
# set KEEP=1 to keep the existing profile.
W=/home/braian/gw005/run
B=/home/braian/gw005/GeniusWallet/build/linux/x64/release/bundle
mkdir -p $W
pkill -x genius_wallet 2>/dev/null; pkill -u braian -x gnome-keyring-d 2>/dev/null; pkill -u braian -x gcr-prompter 2>/dev/null; sleep 2
if [ -z "$KEEP" ]; then rm -rf ~/.local/share/keyrings ~/.local/share/GeniusWallet; fi
{ for kv in "$@"; do printf 'export %q\n' "$kv"; done; } > $W/extra.env
cat > $W/inner.sh <<IN
#!/bin/bash
export DISPLAY=:0 GDK_BACKEND=x11 WEBKIT_DISABLE_COMPOSITING_MODE=\${WEBKIT_DISABLE_COMPOSITING_MODE:-1}
source $W/extra.env
eval "\$(printf 'gwtest' | gnome-keyring-daemon --daemonize --login --components=secrets)"
eval "\$(gnome-keyring-daemon --start --components=secrets)"
export GNOME_KEYRING_CONTROL SSH_AUTH_SOCK
exec $B/genius_wallet
IN
chmod +x $W/inner.sh
if [ -n "$NOWEBKIT" ]; then
  # Hide WebKitGTK: an LD_PRELOAD shim makes its dlopen fail as on a distro without it.
  gcc -shared -fPIC -o /home/braian/gw005/nowebkit.so /mnt/c/Users/User/AppData/Local/Temp/claude/C--Users-User-Documents-Projects-GNUS-GeniusWallet/f900e545-5b78-4fbc-994b-02191fd38bc0/scratchpad/spike/005/nowebkit.c -ldl
  echo "export LD_PRELOAD=/home/braian/gw005/nowebkit.so" >> $W/extra.env
fi
nohup dbus-run-session -- $W/inner.sh > $W/app.log 2>&1 &
sleep ${WAIT:-14}
export DISPLAY=:0
xdotool search --pid $(pgrep -x genius_wallet | head -1) 2>/dev/null | tail -1 > $W/win.id
echo "win=$(cat $W/win.id)"; xdotool getwindowgeometry $(cat $W/win.id)
grep -iE "webview_all|webkit|avail|error|exception" $W/app.log | grep -v Woah | head -10
