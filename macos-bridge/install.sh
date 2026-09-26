#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( dirname "$DIR" )"
PLIST_NAME="com.user.airtag-ha-sync.plist"
TARGET_DIR="$HOME/Library/LaunchAgents"
TARGET_PLIST="$TARGET_DIR/$PLIST_NAME"

echo "=== AirTag to Home Assistant Bridge Installer ==="

# Check config file
if [ ! -f "$PROJECT_DIR/config.yaml" ]; then
    echo "Creating config.yaml from template..."
    cp "$PROJECT_DIR/config.example.yaml" "$PROJECT_DIR/config.yaml"
    echo "⚠️  Please edit '$PROJECT_DIR/config.yaml' and set your Home Assistant URL and Token."
fi

# Ensure LaunchAgents dir exists
mkdir -p "$TARGET_DIR"

# Generate customized plist with actual paths
echo "Configuring LaunchAgent plist..."
sed -e "s|__SCRIPT_PATH__|$DIR/findmy_sync.py|g" \
    -e "s|__CONFIG_PATH__|$PROJECT_DIR/config.yaml|g" \
    "$DIR/launchd/$PLIST_NAME" > "$TARGET_PLIST"

# Make script executable
chmod +x "$DIR/findmy_sync.py"

# Unload previous service if running
launchctl unload "$TARGET_PLIST" 2>/dev/null || true

# Load and start
echo "Loading service into launchd..."
launchctl load -w "$TARGET_PLIST"

echo "✅ Success! AirTag HA Bridge is now running in the background."
echo "Logs are available at /tmp/airtag-ha-sync.log"
