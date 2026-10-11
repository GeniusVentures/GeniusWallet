export PATH="$PATH:/mnt/c/Program Files/Docker/Docker/resources/bin"
S=/mnt/c/Users/User/AppData/Local/Temp/claude/C--Users-User-Documents-Projects-GNUS-GeniusWallet/f900e545-5b78-4fbc-994b-02191fd38bc0/scratchpad/spike/005
sed 's/4\.0/4.1/' /mnt/c/Users/User/Documents/Projects/GNUS/GW-linux-webview/.planning/spikes/003-webkitgtk-40-embed/control-plain-webkit.py > /home/braian/gw005/control41.py
sed -i 's/run_javascript_finish(res).get_js_value()/evaluate_javascript_finish(res)/; s/v.run_javascript(\(.*\), None, done)/v.evaluate_javascript(\1, -1, None, None, None, done)/' /home/braian/gw005/control41.py
docker run --rm -e DISPLAY=:0 -e GDK_BACKEND=x11 -v /tmp/.X11-unix:/tmp/.X11-unix -v /mnt/wslg:/mnt/wslg -v /home/braian/gw005:/w gw005-u2404 \
  python3 /w/control41.py "$1" 40 2>&1 | sed -E 's/initId=[^ ]*/initId=<redacted>/; s/(https:\/\/[^ ?]*)\?[^ ]*/\1?<q>/g' | grep -v "^$" &
sleep 30; W=$(DISPLAY=:0 xdotool search --name '^control$' | tail -1); DISPLAY=:0 import -window $W $S/shots/control41-$2.png; wait
