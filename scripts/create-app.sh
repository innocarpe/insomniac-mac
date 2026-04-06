#!/bin/bash

set -e

echo "📦 Creating Insomniac.app bundle..."

# Clean previous app
rm -rf Insomniac.app

# Create app bundle structure
APP_NAME="Insomniac.app"
CONTENTS="$APP_NAME/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

# Copy executable
cp .build/release/Insomniac "$MACOS/"

# Create Info.plist
cat > "$CONTENTS/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>Insomniac</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.personal.insomniac</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Insomniac</string>
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

# Copy app icon
if [ -f "resources/AppIcon.icns" ]; then
    cp "resources/AppIcon.icns" "$RESOURCES/AppIcon.icns"
elif [ -f "scripts/create-realistic-icon.swift" ]; then
    echo "Generating app icon..."
    ./scripts/create-realistic-icon.swift
else
    touch "$RESOURCES/AppIcon.icns"
fi

# Make executable
chmod +x "$MACOS/Insomniac"

# Ad-hoc sign the app (required for macOS Tahoe+)
codesign --force --deep --sign - "$APP_NAME"

echo "✅ Insomniac.app created successfully!"
echo ""
echo "📝 Installation instructions:"
echo "1. Move Insomniac.app to your Applications folder:"
echo "   mv Insomniac.app /Applications/"
echo ""
echo "2. Open the app for the first time:"
echo "   - Right-click on Insomniac.app in Applications"
echo "   - Select 'Open' from the context menu"
echo "   - Click 'Open' in the security dialog"
echo ""
echo "3. The tea cup icon will appear in your menu bar!"
echo ""
echo "☕ IOPMAssertion API를 사용하므로 관리자 비밀번호가 필요하지 않습니다."