#!/usr/bin/env bash
# Builds genius-wallet .deb and .rpm from a Linux release bundle.
# Usage: tool/package_linux.sh <bundle-dir> <x86_64|aarch64> [out-dir]
# Needs ar, tar, and rpmbuild (rpm-build). No other tooling.
#
# WebKitGTK is dlopen()ed by the app, so it never shows up in ldd; it is
# declared by hand below (4.1 preferred, 4.0 accepted, matching webkit_runtime.cc).
set -euo pipefail

bundle=$(realpath "${1:?bundle dir}")
arch=${2:?x86_64 or aarch64}
out=$(realpath -m "${3:-.}")
root=$(cd "$(dirname "$0")/.." && pwd)

case "$arch" in
  x86_64) deb_arch=amd64 ;;
  aarch64) deb_arch=arm64 ;;
  *) echo "unknown arch: $arch" >&2; exit 1 ;;
esac

version=$(sed -n 's/^version: *\([0-9.]*\).*/\1/p' "$root/pubspec.yaml")
[ -n "$version" ] || { echo "no version in pubspec.yaml" >&2; exit 1; }
[ -x "$bundle/genius_wallet" ] || { echo "$bundle/genius_wallet missing" >&2; exit 1; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
stage="$work/stage"
mkdir -p "$stage/opt" "$stage/usr/bin" "$stage/usr/share/applications" \
  "$stage/usr/share/icons/hicolor/512x512/apps" "$out"
cp -a "$bundle" "$stage/opt/genius-wallet"
ln -s /opt/genius-wallet/genius_wallet "$stage/usr/bin/genius-wallet"
cp "$root/ios/Runner/Assets.xcassets/AppIcon.appiconset/512.png" \
  "$stage/usr/share/icons/hicolor/512x512/apps/genius-wallet.png"
cat > "$stage/usr/share/applications/genius-wallet.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Genius Wallet
Exec=genius-wallet
Icon=genius-wallet
Categories=Finance;Network;
StartupWMClass=ai.gnus.genius_wallet
Terminal=false
DESKTOP
find "$stage" -type d -exec chmod 755 {} +

# deb: an ar archive of debian-binary, control.tar.gz and data.tar.gz, in that order.
deb_depends="libgtk-3-0t64 | libgtk-3-0, libsecret-1-0, libcurl4t64 | libcurl4, libvulkan1, libepoxy0, zlib1g, libstdc++6, libwebkit2gtk-4.1-0 | libwebkit2gtk-4.0-37"
mkdir "$work/control"
cat > "$work/control/control" <<CONTROL
Package: genius-wallet
Version: $version
Architecture: $deb_arch
Maintainer: Genius Ventures <support@gnus.ai>
Installed-Size: $(du -sk "$stage" | cut -f1)
Depends: $deb_depends
Recommends: gnome-keyring
Section: utils
Priority: optional
Description: Genius Wallet
 Self-custody crypto wallet for the Genius network.
CONTROL
tar_opts=(--owner=0 --group=0 --numeric-owner)
tar "${tar_opts[@]}" -czf "$work/control.tar.gz" -C "$work/control" .
tar "${tar_opts[@]}" -czf "$work/data.tar.gz" -C "$stage" .
echo "2.0" > "$work/debian-binary"
deb="$out/genius-wallet_${version}_${deb_arch}.deb"
rm -f "$deb"
(cd "$work" && ar rc "$deb" debian-binary control.tar.gz data.tar.gz)

# rpm: Fedora ships WebKitGTK 4.1 as webkit2gtk4.1, RHEL 8/9 only as webkit2gtk3 (4.0).
# AutoReqProv is off so the bundled .so files do not become unsatisfiable Requires.
cat > "$work/genius-wallet.spec" <<SPEC
Name: genius-wallet
Version: $version
Release: 1
Summary: Genius Wallet
License: Proprietary
AutoReqProv: no
Requires: gtk3, libsecret, libcurl, vulkan-loader, libepoxy, zlib, libstdc++, (webkit2gtk4.1 or webkit2gtk3)
Recommends: gnome-keyring
%global debug_package %{nil}
%global __os_install_post %{nil}
%description
Self-custody crypto wallet for the Genius network.
%install
cp -a $stage/. %{buildroot}/
%files
/opt/genius-wallet
/usr/bin/genius-wallet
/usr/share/applications/genius-wallet.desktop
/usr/share/icons/hicolor/512x512/apps/genius-wallet.png
SPEC
rpmbuild -bb --target "$arch" --define "_topdir $work/rpm" --define "_rpmdir $out" \
  --define "_rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm" "$work/genius-wallet.spec"
ls -l "$out"/genius-wallet*
