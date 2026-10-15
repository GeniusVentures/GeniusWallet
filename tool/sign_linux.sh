#!/usr/bin/env bash
# Signs the .rpm files, writes SHA256SUMS + SHA256SUMS.asc over the tarball and packages.
# Usage: tool/sign_linux.sh <tarball> <packages-dir> <x86_64|aarch64>
# Output is SHA256SUMS-<arch>[.asc]: both arch jobs upload to one release, so names must differ.
# Env: LINUX_SIGNING_KEY (armored private key), LINUX_SIGNING_PASSPHRASE, LINUX_SIGNING_KEY_ID.
# Without them it logs and exits 0, unless SIGNING_REQUIRED=true (publishing runs), which fails.
# Needs gpg and rpmsign (rpm-sign).
set -euo pipefail

tarball=$(realpath "${1:?tarball}")
pkgs=$(realpath "${2:?packages dir}")
arch=${3:?x86_64 or aarch64}

if [ -z "${LINUX_SIGNING_KEY:-}" ] || [ -z "${LINUX_SIGNING_PASSPHRASE:-}" ] || [ -z "${LINUX_SIGNING_KEY_ID:-}" ]; then
  if [ "${SIGNING_REQUIRED:-}" = "true" ]; then
    echo "Signing secrets missing on a publishing run" >&2
    exit 1
  fi
  echo "Signing secrets not available, skipping Linux signing"
  exit 0
fi

work=$(mktemp -d)
chmod 700 "$work"
trap 'gpgconf --kill gpg-agent 2>/dev/null || true; rm -rf "$work"' EXIT
export GNUPGHOME="$work/gnupg"
mkdir -m 700 "$GNUPGHOME"
umask 077
printf '%s' "$LINUX_SIGNING_PASSPHRASE" > "$work/pass"
printf '%s\n' "$LINUX_SIGNING_KEY" | gpg --batch --quiet --import

# The checked-in public key is the pin: the imported secret key must be its pair.
pinned=$(gpg --show-keys --with-colons "$(dirname "$0")/../linux/packaging/genius-wallet-signing.pub.asc" | awk -F: '/^fpr/{print $10; exit}')
imported=$(gpg --list-secret-keys --with-colons | awk -F: '/^fpr/{print $10; exit}')
if [ -z "$pinned" ] || [ "$imported" != "$pinned" ] || [ "$LINUX_SIGNING_KEY_ID" != "$pinned" ]; then
  echo "Signing key does not match linux/packaging/genius-wallet-signing.pub.asc" >&2
  exit 1
fi

gpgsign=(gpg --batch --no-tty --pinentry-mode loopback --passphrase-file "$work/pass" -u "$LINUX_SIGNING_KEY_ID")

shopt -s nullglob
for rpm in "$pkgs"/*.rpm; do
  rpmsign --addsign \
    --define "_gpg_name $LINUX_SIGNING_KEY_ID" \
    --define "__gpg_sign_cmd %{__gpg} gpg --batch --no-tty --no-armor --pinentry-mode loopback --passphrase-file $work/pass -u %{_gpg_name} --digest-algo sha256 -sbo %{__signature_filename} %{__plaintext_filename}" \
    "$rpm"
done

# SHA256SUMS lists bare file names so `sha256sum -c` works in the download directory.
sums="$pkgs/SHA256SUMS-$arch"
{
  cd "$(dirname "$tarball")" && sha256sum "$(basename "$tarball")"
  cd "$pkgs" && sha256sum *.deb *.rpm
} > "$sums"
rm -f "$sums.asc"
"${gpgsign[@]}" --armor --detach-sign -o "$sums.asc" "$sums"
cp "$(dirname "$0")/../linux/packaging/genius-wallet-signing.pub.asc" "$pkgs/"
echo "Signed: $(ls "$pkgs")"
