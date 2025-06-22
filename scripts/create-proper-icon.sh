#!/bin/bash

echo "🎨 Creating proper app icon with iconutil..."

# Create iconset directory
ICONSET="Caffeine.iconset"
rm -rf "$ICONSET"
mkdir -p "$ICONSET"

# Create a simple Swift script to generate images
cat > /tmp/icon_generator.swift << 'EOF'
import AppKit

let sizes = [16, 32, 128, 256, 512]
let scales = [1, 2]

for size in sizes {
    for scale in scales {
        let actualSize = size * scale
        let filename = scale == 1 ? "icon_\(size)x\(size).png" : "icon_\(size)x\(size)@\(scale)x.png"
        
        let image = NSImage(size: NSSize(width: actualSize, height: actualSize))
        image.lockFocus()
        
        // Background gradient
        let gradient = NSGradient(colors: [
            NSColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0),
            NSColor(red: 0.2, green: 0.15, blue: 0.1, alpha: 1.0)
        ])
        gradient?.draw(in: NSRect(x: 0, y: 0, width: actualSize, height: actualSize), angle: -45)
        
        // Draw coffee cup
        let cupSize = CGFloat(actualSize) * 0.7
        let cupX = (CGFloat(actualSize) - cupSize) / 2
        let cupY = (CGFloat(actualSize) - cupSize) / 2
        
        // Cup body
        let cupPath = NSBezierPath()
        cupPath.move(to: NSPoint(x: cupX + cupSize * 0.2, y: cupY + cupSize * 0.8))
        cupPath.line(to: NSPoint(x: cupX + cupSize * 0.3, y: cupY + cupSize * 0.2))
        cupPath.line(to: NSPoint(x: cupX + cupSize * 0.7, y: cupY + cupSize * 0.2))
        cupPath.line(to: NSPoint(x: cupX + cupSize * 0.8, y: cupY + cupSize * 0.8))
        cupPath.close()
        
        NSColor.white.setFill()
        cupPath.fill()
        
        // Handle
        let handlePath = NSBezierPath()
        handlePath.appendArc(withCenter: NSPoint(x: cupX + cupSize * 0.8, y: cupY + cupSize * 0.5),
                            radius: cupSize * 0.15,
                            startAngle: -30,
                            endAngle: 30)
        handlePath.lineWidth = CGFloat(actualSize) * 0.03
        NSColor.white.setStroke()
        handlePath.stroke()
        
        // Steam
        for i in 0..<3 {
            let steamPath = NSBezierPath()
            let xOffset = cupX + cupSize * (0.4 + CGFloat(i) * 0.1)
            steamPath.move(to: NSPoint(x: xOffset, y: cupY + cupSize * 0.8))
            steamPath.curve(to: NSPoint(x: xOffset + cupSize * 0.05, y: cupY + cupSize * 1.1),
                           controlPoint1: NSPoint(x: xOffset - cupSize * 0.05, y: cupY + cupSize * 0.9),
                           controlPoint2: NSPoint(x: xOffset + cupSize * 0.05, y: cupY + cupSize * 1.0))
            steamPath.lineWidth = CGFloat(actualSize) * 0.02
            NSColor(white: 1.0, alpha: 0.5).setStroke()
            steamPath.stroke()
        }
        
        image.unlockFocus()
        
        if let tiffData = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            try? pngData.write(to: URL(fileURLWithPath: "Caffeine.iconset/\(filename)"))
        }
    }
}
EOF

# Run the generator
swift /tmp/icon_generator.swift

# Convert to icns
iconutil -c icns "$ICONSET" -o "Caffeine.app/Contents/Resources/AppIcon.icns"

# Clean up
rm -rf "$ICONSET"
rm -f /tmp/icon_generator.swift

# Fix permissions and clear caches
chmod 644 "Caffeine.app/Contents/Resources/AppIcon.icns"
xattr -cr Caffeine.app
codesign --force --deep --sign - Caffeine.app

# Refresh Finder
touch Caffeine.app
killall Finder

echo "✅ Icon created and installed!"
echo ""
echo "The app should now show the coffee cup icon in Finder."