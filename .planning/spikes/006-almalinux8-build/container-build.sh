export PATH="$PATH:/mnt/c/Program Files/Docker/Docker/resources/bin"
MODE=${1:-debug}
docker run --rm -v /home/braian/spike006:/work -w /work/spike_app gw-spike006 bash -c "
rpm -q webkit2gtk3 webkit2gtk3-devel webkit2gtk3-jsc glib2 libsoup gtk3 gstreamer1 gstreamer1-plugins-base
pkg-config --modversion webkit2gtk-4.0 libsoup-2.4 glib-2.0
flutter pub get >/dev/null 2>&1 || flutter pub get
start=\$(date +%s)
CMAKE_ARGUMENTS='-DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++' \
  flutter build linux --$MODE 2>&1 | grep -v 'Woah\|superuser\|^ */$\|📎' | tail -40
echo BUILD_SECONDS=\$((\$(date +%s)-start))
chown -R $(id -u):$(id -g) /work
"
