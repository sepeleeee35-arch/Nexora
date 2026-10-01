#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.47.2"
FLUTTER_DIR="/tmp/flutter"

echo "==> Downloading Flutter ${FLUTTER_VERSION}"
curl -fL --retry 3 "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -o /tmp/flutter.tar.xz

echo "==> Extracting Flutter"
rm -rf "$FLUTTER_DIR"
tar -xJf /tmp/flutter.tar.xz -C /tmp

export PATH="$FLUTTER_DIR/bin:$PATH"

echo "==> Flutter version"
flutter --version

echo "==> Enabling Flutter Web"
flutter config --enable-web

echo "==> Generating web platform files"
flutter create . --platforms=web

echo "==> Installing Dart packages"
flutter pub get

echo "==> Building Nexora Web"
flutter build web --release

echo "==> Build output"
test -f build/web/index.html
ls -la build/web
