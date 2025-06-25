#!/usr/bin/swift

import AppKit
import Foundation

// Check if source image path is provided
guard CommandLine.arguments.count > 1 else {
    print("❌ Usage: swift create-icon-from-image.swift <source-image-path>")
    exit(1)
}

let sourceImagePath = CommandLine.arguments[1]

// Check if source image exists
guard FileManager.default.fileExists(atPath: sourceImagePath) else {
    print("❌ Source image not found: \(sourceImagePath)")
    exit(1)
}

// Load source image
guard let sourceImage = NSImage(contentsOfFile: sourceImagePath) else {
    print("❌ Failed to load image: \(sourceImagePath)")
    exit(1)
}

func createIconFromImage(sourceImage: NSImage, size: CGFloat) -> NSImage? {
    let image = NSImage(size: NSSize(width: size, height: size))
    
    image.lockFocus()
    
    // Clear background
    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: size, height: size).fill()
    
    // Draw source image resized to fit
    sourceImage.draw(in: NSRect(x: 0, y: 0, width: size, height: size))
    
    image.unlockFocus()
    
    return image
}

// Generate iconset
let iconsetPath = "Insomniac.iconset"
try? FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

let sizes: [(Int, Int)] = [
    (16, 1), (16, 2),
    (32, 1), (32, 2),
    (128, 1), (128, 2),
    (256, 1), (256, 2),
    (512, 1), (512, 2)
]

print("🎨 Creating app icon from source image...")

for (baseSize, scale) in sizes {
    let actualSize = baseSize * scale
    let suffix = scale > 1 ? "@\(scale)x" : ""
    let filename = "icon_\(baseSize)x\(baseSize)\(suffix).png"
    let filepath = "\(iconsetPath)/\(filename)"
    
    if let icon = createIconFromImage(sourceImage: sourceImage, size: CGFloat(actualSize)) {
        if let tiffData = icon.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            try? pngData.write(to: URL(fileURLWithPath: filepath))
            print("  ✓ Created: \(filename)")
        }
    }
}

print("\n📦 Converting to .icns...")

// Convert to icns
let task = Process()
task.launchPath = "/usr/bin/iconutil"
task.arguments = ["-c", "icns", iconsetPath, "-o", "Insomniac.app/Contents/Resources/AppIcon.icns"]
task.launch()
task.waitUntilExit()

// Clean up
try? FileManager.default.removeItem(atPath: iconsetPath)

// Refresh
let refreshTask = Process()
refreshTask.launchPath = "/usr/bin/touch"
refreshTask.arguments = ["Insomniac.app"]
refreshTask.launch()
refreshTask.waitUntilExit()

print("\n✅ App icon created from source image!")
print("🖼️ The app now uses your custom icon!")