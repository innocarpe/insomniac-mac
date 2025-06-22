#!/bin/bash

set -e

echo "🔨 Building Caffeine..."

# Clean previous builds
rm -rf .build
rm -rf Caffeine.app

# Build the app
swift build -c release

# Create app bundle structure
mkdir -p Caffeine.app/Contents/MacOS
mkdir -p Caffeine.app/Contents/Resources

# Copy executable
cp .build/release/Caffeine Caffeine.app/Contents/MacOS/

# Copy Info.plist
cp Sources/Caffeine/Resources/Info.plist Caffeine.app/Contents/

# Create a simple icon (we'll use text for now)
cat > Caffeine.app/Contents/Resources/AppIcon.icns << 'EOF'
☕️
EOF

echo "✅ Build complete!"
echo "📦 Caffeine.app created"
echo ""
echo "To install:"
echo "1. Copy Caffeine.app to /Applications"
echo "2. Right-click and select 'Open' for first launch"
echo "3. Grant accessibility permissions if prompted"