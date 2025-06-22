#!/bin/bash

echo "🔧 Fixing app icon..."

# Remove old attributes
xattr -cr Caffeine.app

# Touch the app to refresh
touch Caffeine.app

# Re-sign the app
codesign --force --deep --sign - Caffeine.app

# Clear icon cache
sudo rm -rf /Library/Caches/com.apple.iconservices.store
killall Dock
killall Finder

echo "✅ Icon fix complete!"
echo ""
echo "The app icon should now be visible in Finder."
echo "If not, try:"
echo "1. Move the app to a different folder and back"
echo "2. Log out and log back in"
echo "3. Restart your Mac"