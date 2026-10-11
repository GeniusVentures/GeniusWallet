#!/bin/bash
# Wallet Linux release build in the EL8 CI image (gw-spike006 = CI image + webkit2gtk3-devel + Flutter 3.41.9).
export PATH="$PATH:/mnt/c/Program Files/Docker/Docker/resources/bin"
D=/home/braian/gw005
docker run --rm -v $D:/src -v gw005-pubcache:/root/.pub-cache -w /src/GeniusWallet gw-spike006 bash -c "
set -o pipefail
git config --global --add safe.directory '*'
[ -n \"$CLEAN\" ] && rm -rf build/linux
flutter pub get 2>&1 | tail -5
start=\$(date +%s)
export CMAKE_GENERATOR=Ninja CC=/usr/bin/clang CXX=/usr/bin/clang++ ASM=/usr/bin/clang
CMAKE_ARGUMENTS='-DCMAKE_BUILD_TYPE=Release -DGENIUS_DEPENDENCY_BRANCH=develop -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DCMAKE_C_FLAGS=-Wno-deprecated-literal-operator -DCMAKE_CXX_FLAGS=-Wno-deprecated-literal-operator' \
  flutter build linux --release --dart-define=GW_BANXA_SANDBOX=true --dart-define=GW_BANXA_TEST_COIN=ETH \${EXTRA_DEFINES:-} > /src/build.log 2>&1
rc=\$?
echo BUILD_RC=\$rc BUILD_SECONDS=\$((\$(date +%s)-start))
tail -30 /src/build.log | grep -v Woah
B=build/linux/x64/release/bundle
ls -l \$B/lib 2>/dev/null; du -sb \$B 2>/dev/null
chown -R $(id -u):$(id -g) /src
"
