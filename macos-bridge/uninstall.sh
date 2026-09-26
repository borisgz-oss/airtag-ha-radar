#!/usr/bin/env bash
set -e

PLIST_NAME="com.user.airtag-ha-sync.plist"
TARGET_PLIST="$HOME/Library/LaunchAgents/$PLIST_NAME"

echo "=== Uninstalling AirTag HA Bridge ==="

if [ -f "$TARGET_PLIST" ]; then
    echo "Stopping background daemon..."
    launchctl unload "$TARGET_PLIST" 2>/dev/null || true
    rm -f "$TARGET_PLIST"
    echo "✅ Removed LaunchAgent plist."
else
    echo "LaunchAgent not found, skipping."
fi

# Clean up temp logs
rm -f /tmp/airtag-ha-sync.log /tmp/airtag-ha-sync.err

echo "✅ Uninstallation complete. No background processes remain."
