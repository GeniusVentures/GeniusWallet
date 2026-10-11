#!/bin/bash
# Mirror the worktree (and the main repo's submodule checkouts) into WSL ext4 for the container build.
set -e
D=/home/braian/gw005
mkdir -p $D/GeniusWallet
rsync -a --delete --exclude /.git --exclude /build --exclude /.dart_tool --exclude /.planning --exclude /.claude --exclude /.gsd --exclude .dart_tool --exclude /pubspec.lock.win \
  --exclude /banxa --exclude /squidrouter --exclude /tokeninfo \
  /mnt/c/Users/User/Documents/Projects/GNUS/GW-linux-webview/ $D/GeniusWallet/
for s in banxa squidrouter tokeninfo; do
  rsync -a --delete --exclude .git --exclude .dart_tool --exclude build /mnt/c/Users/User/Documents/Projects/GNUS/GeniusWallet/$s/ $D/GeniusWallet/$s/
done
du -sh $D/GeniusWallet
