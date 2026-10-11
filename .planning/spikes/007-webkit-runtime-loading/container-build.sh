# Builds the spike app in the EL8 CI image (+ webkit2gtk3-devel for headers). Run from WSL.
export PATH="$PATH:/mnt/c/Program Files/Docker/Docker/resources/bin"
MODE=${1:-release}
docker run --rm -v /home/braian/spike007:/work -w /work/spike_app gw-spike006 bash -c "
flutter pub get >/dev/null 2>&1 || flutter pub get
start=\$(date +%s)
CMAKE_ARGUMENTS='-DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++' \
  flutter build linux --$MODE 2>&1 | grep -v 'Woah\|superuser\|^ */$\|📎' | tail -40
echo BUILD_SECONDS=\$((\$(date +%s)-start))
B=build/linux/x64/$MODE/bundle
echo '== NEEDED (exe + plugin)'; readelf -d \$B/spike_app \$B/lib/libwebview_all_linux_plugin.so | grep NEEDED
echo '== undefined webkit/soup/jsc in plugin'; nm -D --undefined-only \$B/lib/libwebview_all_linux_plugin.so | grep -Eic ' (webkit|soup|jsc)_' || true
ls -l \$B/lib/libwebview_all_linux_plugin.so; du -sb \$B
chown -R $(id -u):$(id -g) /work
"
