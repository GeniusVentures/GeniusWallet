#!/usr/bin/env bash
set -euo pipefail

FLUTTER_PARENT="../flutter"
THIRDPARTY_DIR="$FLUTTER_PARENT"
FLUTTER_DIR="$FLUTTER_PARENT/flutter"

echo "🔍 Checking flutter installation target: $FLUTTER_DIR"

# Ensure parent directory exists
mkdir -p "$FLUTTER_PARENT"

if [ ! -d "$THIRDPARTY_DIR/.git" ]; then
  echo "📦 Cloning thirdparty into $THIRDPARTY_DIR..."
  git clone git@github.com:GeniusVentures/thirdparty.git "$THIRDPARTY_DIR"
else
  echo "✅ thirdparty already exists and is a Git repo."
fi

cd "$THIRDPARTY_DIR"

echo "📥 Initializing flutter submodule..."
git submodule update --init --recursive -- flutter

cd flutter
FLUTTER_BIN_DIR="$(pwd)/bin"

echo "✅ Flutter is installed:"
"$FLUTTER_BIN_DIR/flutter" --version

echo
echo "🛠️  To use Flutter now, run:"
echo "    export PATH=\"$FLUTTER_BIN_DIR:\$PATH\""
echo
echo "🔒 To make it permanent, add it to your ~/.bashrc or ~/.zshrc"
