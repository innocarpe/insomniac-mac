#!/bin/bash

set -e

echo "📦 Creating Caffeine.app bundle..."

# Clean previous app
rm -rf Caffeine.app

# Create app bundle structure
APP_NAME="Caffeine.app"
CONTENTS="$APP_NAME/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

# Copy executable
cp .build/release/Caffeine "$MACOS/"

# Create Info.plist
cat > "$CONTENTS/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>Caffeine</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.personal.caffeine</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Caffeine</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

# Copy existing icon or create new one
if [ -f "Caffeine.app/Contents/Resources/AppIcon.icns" ] && [ -s "Caffeine.app/Contents/Resources/AppIcon.icns" ]; then
    cp "Caffeine.app/Contents/Resources/AppIcon.icns" "$RESOURCES/AppIcon.icns"
else
    # Generate icon if it doesn't exist
    if [ -f "scripts/create-realistic-icon.swift" ]; then
        echo "Generating app icon..."
        ./scripts/create-realistic-icon.swift
    else
        touch "$RESOURCES/AppIcon.icns"
    fi
fi

# Make executable
chmod +x "$MACOS/Caffeine"

# Sign the app (if you have a developer certificate)
# codesign --force --deep --sign - "$APP_NAME"

echo "✅ Caffeine.app created successfully!"
echo ""
echo "📝 Installation instructions:"
echo "1. Move Caffeine.app to your Applications folder:"
echo "   mv Caffeine.app /Applications/"
echo ""
echo "2. Open the app for the first time:"
echo "   - Right-click on Caffeine.app in Applications"
echo "   - Select 'Open' from the context menu"
echo "   - Click 'Open' in the security dialog"
echo ""
echo "3. The coffee cup icon will appear in your menu bar!"
echo ""
echo "⚠️  Note: The app will ask for administrator password when toggling caffeine mode."