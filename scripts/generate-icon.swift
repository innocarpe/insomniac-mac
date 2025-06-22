#!/usr/bin/swift

import AppKit
import Foundation

func createCoffeeIcon(size: CGFloat, filled: Bool = true) -> NSImage? {
    let image = NSImage(size: NSSize(width: size, height: size))
    
    image.lockFocus()
    
    // Clear background
    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: size, height: size).fill()
    
    // Dark background circle
    let backgroundPath = NSBezierPath(ovalIn: NSRect(x: size * 0.1, y: size * 0.1, 
                                                     width: size * 0.8, height: size * 0.8))
    NSColor(white: 0.2, alpha: 1.0).setFill()
    backgroundPath.fill()
    
    // Coffee cup using emoji
    let fontSize = size * 0.5
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: fontSize),
        .foregroundColor: filled ? NSColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0) : 
                                  NSColor(white: 0.5, alpha: 1.0),
        .paragraphStyle: paragraphStyle
    ]
    
    let emoji = filled ? "☕" : "🥤"
    let textRect = NSRect(x: 0, y: (size - fontSize) / 2 - size * 0.05, 
                         width: size, height: fontSize)
    emoji.draw(in: textRect, withAttributes: attributes)
    
    image.unlockFocus()
    
    return image
}

func generateIconset() {
    let iconsetPath = "Caffeine.iconset"
    try? FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)
    
    let sizes: [(Int, Int)] = [
        (16, 1), (16, 2),
        (32, 1), (32, 2),
        (128, 1), (128, 2),
        (256, 1), (256, 2),
        (512, 1), (512, 2)
    ]
    
    for (baseSize, scale) in sizes {
        let actualSize = baseSize * scale
        let suffix = scale > 1 ? "@\(scale)x" : ""
        let filename = "icon_\(baseSize)x\(baseSize)\(suffix).png"
        let filepath = "\(iconsetPath)/\(filename)"
        
        if let icon = createCoffeeIcon(size: CGFloat(actualSize)) {
            if let tiffData = icon.tiffRepresentation,
               let bitmap = NSBitmapImageRep(data: tiffData),
               let pngData = bitmap.representation(using: .png, properties: [:]) {
                try? pngData.write(to: URL(fileURLWithPath: filepath))
                print("Created: \(filename)")
            }
        }
    }
    
    print("\nConverting to .icns...")
    
    // Create Resources directory if needed
    try? FileManager.default.createDirectory(atPath: "Caffeine.app/Contents/Resources", 
                                           withIntermediateDirectories: true)
    
    // Convert iconset to icns
    let task = Process()
    task.launchPath = "/usr/bin/iconutil"
    task.arguments = ["-c", "icns", iconsetPath, "-o", "Caffeine.app/Contents/Resources/AppIcon.icns"]
    task.launch()
    task.waitUntilExit()
    
    // Clean up
    try? FileManager.default.removeItem(atPath: iconsetPath)
    
    print("✅ Icon created: Caffeine.app/Contents/Resources/AppIcon.icns")
}

// Run the icon generation
print("🎨 Generating app icon...")
generateIconset()