#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.47.2"
GOOGLE_CLIENT_ID="884139341759-mrna2bd2a81d1dpj2nofbondk75i8lno.apps.googleusercontent.com"
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

echo "==> Creating web platform files"
flutter create . --platforms=web

echo "==> Installing Dart packages"
flutter pub get

echo "==> Configure Google Sign-In web client"
python3 - <<'PY'
from pathlib import Path
client = "884139341759-mrna2bd2a81d1dpj2nofbondk75i8lno.apps.googleusercontent.com"
p = Path("web/index.html")
s = p.read_text()
s = "\n".join(x for x in s.splitlines() if "google-signin-client_id" not in x) + "\n"
s = s.replace("<head>", '<head>\n    <meta name="google-signin-client_id" content="' + client + '">', 1)
p.write_text(s)
PY

echo "==> Building Nexora Web"
flutter build web --release --no-wasm-dry-run --dart-define=GOOGLE_CLIENT_ID="884139341759-mrna2bd2a81d1dpj2nofbondk75i8lno.apps.googleusercontent.com" --dart-define=GOOGLE_SERVER_CLIENT_ID="884139341759-mrna2bd2a81d1dpj2nofbondk75i8lno.apps.googleusercontent.com"

echo "==> Checking build output"
test -f build/web/index.html
test -d build/web
ls -la build/web
