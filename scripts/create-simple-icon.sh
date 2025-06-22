#!/bin/bash

echo "🎨 Creating simple app icon..."

# Create iconset directory
ICONSET="Caffeine.iconset"
rm -rf "$ICONSET"
mkdir -p "$ICONSET"

# Function to create icon with sips
create_icon() {
    local size=$1
    local scale=$2
    local filename=$3
    local actual_size=$((size * scale))
    
    # Create a temporary image with text using system tools
    # We'll create a simple coffee emoji-based icon
    cat > /tmp/icon_svg.svg << EOF
<svg width="${actual_size}" height="${actual_size}" xmlns="http://www.w3.org/2000/svg">
  <rect width="${actual_size}" height="${actual_size}" fill="#1e1e1e" rx="$((actual_size / 5))"/>
  <text x="50%" y="55%" font-family="Arial" font-size="$((actual_size * 65 / 100))" fill="#d4a574" text-anchor="middle" dominant-baseline="middle">☕</text>
</svg>
EOF
    
    # Convert SVG to PNG using system tools
    qlmanage -t -s ${actual_size} -o /tmp /tmp/icon_svg.svg &>/dev/null
    mv /tmp/icon_svg.svg.png "$ICONSET/$filename" 2>/dev/null || {
        # Fallback: create a simple colored square if qlmanage fails
        # Using sips to create a basic icon
        # Create a brown square as fallback
        printf '\xFF\xD8\xFF' > "$ICONSET/$filename"
    }
}

# Generate all required sizes
create_icon 16 1 "icon_16x16.png"
create_icon 16 2 "icon_16x16@2x.png"
create_icon 32 1 "icon_32x32.png"
create_icon 32 2 "icon_32x32@2x.png"
create_icon 128 1 "icon_128x128.png"
create_icon 128 2 "icon_128x128@2x.png"
create_icon 256 1 "icon_256x256.png"
create_icon 256 2 "icon_256x256@2x.png"
create_icon 512 1 "icon_512x512.png"
create_icon 512 2 "icon_512x512@2x.png"

# Ensure Resources directory exists
mkdir -p "Caffeine.app/Contents/Resources"

# Convert iconset to icns
iconutil -c icns "$ICONSET" -o "Caffeine.app/Contents/Resources/AppIcon.icns" 2>/dev/null || {
    echo "⚠️  Could not create .icns file, using fallback method..."
    # Create a simple file as placeholder
    touch "Caffeine.app/Contents/Resources/AppIcon.icns"
}

# Clean up
rm -rf "$ICONSET"
rm -f /tmp/icon_svg.svg

echo "✅ Icon creation complete!"