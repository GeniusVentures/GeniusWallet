#!/usr/bin/env bash
# Self-check for sign_linux.sh with throwaway keys. Needs gpg, rpmbuild, rpmsign.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
work=$(mktemp -d)
trap 'gpgconf --kill gpg-agent 2>/dev/null || true; rm -rf "$work"' EXIT
export GNUPGHOME="$work/gnupg"
mkdir -m 700 "$GNUPGHOME"

mkkey() { # name -> $work/name.key, $work/name.pub, prints fingerprint
  gpg --batch --quiet --pinentry-mode loopback --passphrase pw --quick-gen-key "$1 <$1@test>" rsa2048 sign 1d 2>/dev/null
  local fpr
  fpr=$(gpg --list-keys --with-colons "$1@test" | awk -F: '/^fpr/{print $10; exit}')
  gpg --batch --pinentry-mode loopback --passphrase pw --armor --export-secret-keys "$fpr" > "$work/$1.key"
  gpg --armor --export "$fpr" > "$work/$1.pub"
  gpg --batch --quiet --yes --delete-secret-and-public-keys "$fpr" 2>/dev/null
  echo "$fpr"
}
good=$(mkkey good)
other=$(mkkey other)

mkdir -p "$work/rpm/SPECS" "$work/pk"
printf 'Name: t\nVersion: 1\nRelease: 1\nSummary: t\nLicense: MIT\n%%description\nt\n%%files\n' > "$work/rpm/SPECS/t.spec"
rpmbuild -bb --define "_topdir $work/rpm" "$work/rpm/SPECS/t.spec" >/dev/null 2>&1
cp "$work"/rpm/RPMS/*/t-1-1.*.rpm "$work/pk/"
echo deb > "$work/pk/t.deb"
echo tar > "$work/pk/a.tar.gz"

sign() { # key-name key-fpr
  LINUX_SIGNING_KEY=$(cat "$work/$1.key") LINUX_SIGNING_PASSPHRASE=pw LINUX_SIGNING_KEY_ID=$2 \
    SIGNING_REQUIRED=true PINNED_PUBKEY="$work/good.pub" bash "$here/sign_linux.sh" "$work/pk/a.tar.gz" "$work/pk" x86_64
}

if sign other "$other" 2>/dev/null; then echo "FAIL: mismatched key was accepted" >&2; exit 1; fi
[ ! -e "$work/pk/SHA256SUMS-x86_64" ] || { echo "FAIL: mismatch left output" >&2; exit 1; }
sign good "$good"

gpg --batch --quiet --import "$work/good.pub"
gpg --verify "$work/pk/SHA256SUMS-x86_64.asc" "$work/pk/SHA256SUMS-x86_64" 2>/dev/null
(cd "$work/pk" && sha256sum -c SHA256SUMS-x86_64 >/dev/null)
rdb="$work/rpmdb"
rpmkeys --dbpath "$rdb" --import "$work/good.pub"
rpmkeys --dbpath "$rdb" -K "$work"/pk/*.rpm | grep -q 'signatures OK'
echo "sign_linux self-check passed"
