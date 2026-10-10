# syntax=docker/dockerfile:1
# Anthropic OSS Scanner prepares a Flutter/Dart build of GeniusWallet develop
# on the same AlmaLinux 8 base as native GNUS.ai CI.
FROM ghcr.io/geniusventures/almalinux-8:latest

ENV CI=1 \
    FLUTTER_ROOT=/opt/flutter \
    PUB_CACHE=/root/.pub-cache \
    PATH=/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:$PATH

# Flutter needs xz/unzip to extract its cached SDK and Linux engine.
RUN dnf install -y ca-certificates git curl xz unzip zip file \
 && dnf clean all

# Pin Flutter to the version in the existing GeniusWallet develop CI.
# GitHub's tag checkout is shallow; no user credentials are required.
RUN git clone --depth 1 --branch 3.41.9 \
      https://github.com/flutter/flutter.git /opt/flutter \
 && flutter --version \
 && flutter config --enable-linux-desktop \
 && flutter precache --linux

WORKDIR /src
COPY . /src

# Keep public local-package submodule revisions pinned to the wallet checkout.
RUN git config --global --add url."https://github.com/".insteadOf "git@github.com:" \
 && git submodule sync --recursive \
 && git submodule update --init --recursive

# Build the Linux x86_64 Dart/Flutter asset bundle (offline-friendly).
# Without --target-platform, Flutter defaults to Android and requires Android SDK. This prepares
# application Dart, assets, package sources and toolchain for the scanner.
# Native Linux desktop/C++ integration needs a separate full-build verification.
RUN flutter pub get \
 && flutter build bundle --release --no-pub --target-platform linux-x64 \
 && test -d build/flutter_assets

CMD ["/bin/bash"]
