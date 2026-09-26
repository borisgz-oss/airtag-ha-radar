#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_NAME="AirTag HA Radar"
BUILD_DIR="$DIR/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo "=== Building $APP_NAME for macOS ==="

rm -rf "$BUILD_DIR"
mkdir -p "$MACOS" "$RESOURCES"

# Compile Swift code
echo "Compiling native Swift binary..."
swiftc -O -parse-as-library \
    -target arm64-apple-macos14.0 \
    -o "$MACOS/AirTagRadar" \
    "$DIR/Sources/main.swift"

# Create Info.plist
cat <<EOF > "$CONTENTS/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>AirTagRadar</string>
    <key>CFBundleIdentifier</key>
    <string>com.boris.airtag-ha-radar</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

chmod +x "$MACOS/AirTagRadar"

echo "✅ Build successful!"
echo "App bundle created at: $APP_BUNDLE"
