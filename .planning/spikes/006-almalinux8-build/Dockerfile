# CI image + what the in-app webview needs. Flutter mirrors build.yml's pin.
FROM ghcr.io/geniusventures/almalinux-8:latest
RUN dnf install -y ninja-build vulkan-loader-devel libsecret-devel libzstd-devel gtk3-devel jq \
      webkit2gtk3-devel \
    && dnf clean all
# Runtime-only extras for the local walk, not needed in CI: GL drivers and fonts for WSLg.
RUN dnf install -y mesa-dri-drivers mesa-libGL dejavu-sans-fonts xz which && dnf clean all
RUN curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.41.9-stable.tar.xz \
      | tar -xJ -C /opt && git config --global --add safe.directory '*'
ENV PATH=/opt/flutter/bin:$PATH
RUN flutter config --no-analytics --enable-linux-desktop && flutter precache --linux && flutter --version
