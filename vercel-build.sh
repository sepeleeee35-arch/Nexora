#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.47.2"
FLUTTER_DIR="/tmp/flutter"
ARCHIVE="/tmp/flutter.tar.xz"

echo "==> Downloading Flutter $FLUTTER_VERSION"
curl -fL --retry 3 --retry-delay 2 \
  "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.2-stable.tar.xz" \
  -o "$ARCHIVE"

echo "==> Extracting Flutter"
rm -rf "$FLUTTER_DIR"
tar -xJf "$ARCHIVE" -C /tmp
git config --global --add safe.directory "$FLUTTER_DIR"

export PATH="$FLUTTER_DIR/bin:$PATH"

echo "==> Flutter version"
flutter --version

echo "==> Enabling Flutter Web"
flutter config --enable-web

echo "==> Installing Dart packages"
flutter pub get

echo "==> Building Nexora Web"
flutter build web --release --no-wasm-dry-run

echo "==> Checking build output"
test -f build/web/index.html
test -d build/web
ls -la build/web
