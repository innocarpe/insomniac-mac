#!/usr/bin/swift

import AppKit
import Foundation

func createRealisticCoffeeIcon(size: CGFloat) -> NSImage? {
    let image = NSImage(size: NSSize(width: size, height: size))
    
    image.lockFocus()
    
    // Clear background
    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: size, height: size).fill()
    
    // Enable anti-aliasing
    NSGraphicsContext.current?.shouldAntialias = true
    NSGraphicsContext.current?.imageInterpolation = .high
    
    // Dark background with subtle gradient
    let backgroundGradient = NSGradient(colors: [
        NSColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0),
        NSColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1.0)
    ])
    let backgroundRect = NSRect(x: 0, y: 0, width: size, height: size)
    let backgroundPath = NSBezierPath(roundedRect: backgroundRect, xRadius: size * 0.15, yRadius: size * 0.15)
    backgroundGradient?.draw(in: backgroundPath, angle: -45)
    
    // Scale for elements
    let scale = size / 100.0
    
    // Saucer
    let saucerY = size * 0.25
    let saucerWidth = size * 0.65
    let saucerHeight = size * 0.12
    let saucerX = (size - saucerWidth) / 2
    
    // Saucer shadow
    let shadowPath = NSBezierPath(ovalIn: NSRect(
        x: saucerX - 2 * scale,
        y: saucerY - 3 * scale,
        width: saucerWidth + 4 * scale,
        height: saucerHeight + 2 * scale
    ))
    NSColor(white: 0, alpha: 0.3).setFill()
    shadowPath.fill()
    
    // Saucer gradient
    let saucerGradient = NSGradient(colors: [
        NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0),
        NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0),
        NSColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
    ])
    let saucerPath = NSBezierPath(ovalIn: NSRect(x: saucerX, y: saucerY, width: saucerWidth, height: saucerHeight))
    saucerGradient?.draw(in: saucerPath, angle: 90)
    
    // Saucer rim highlight
    let rimPath = NSBezierPath(ovalIn: NSRect(
        x: saucerX + saucerWidth * 0.1,
        y: saucerY + saucerHeight * 0.2,
        width: saucerWidth * 0.8,
        height: saucerHeight * 0.6
    ))
    NSColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.7).setStroke()
    rimPath.lineWidth = 1.0 * scale
    rimPath.stroke()
    
    // Cup body
    let cupBottom = saucerY + saucerHeight * 0.7
    let cupTop = size * 0.65
    let cupHeight = cupTop - cupBottom
    let cupBottomWidth = size * 0.35
    let cupTopWidth = size * 0.45
    let cupX = (size - cupBottomWidth) / 2
    
    // Cup shadow
    let cupShadowPath = NSBezierPath()
    cupShadowPath.move(to: NSPoint(x: cupX - 2 * scale, y: cupBottom - 2 * scale))
    cupShadowPath.line(to: NSPoint(x: (size - cupTopWidth) / 2 - 2 * scale, y: cupTop - 2 * scale))
    cupShadowPath.line(to: NSPoint(x: (size + cupTopWidth) / 2 + 2 * scale, y: cupTop - 2 * scale))
    cupShadowPath.line(to: NSPoint(x: cupX + cupBottomWidth + 2 * scale, y: cupBottom - 2 * scale))
    cupShadowPath.close()
    NSColor(white: 0, alpha: 0.2).setFill()
    cupShadowPath.fill()
    
    // Cup gradient
    let cupGradient = NSGradient(colors: [
        NSColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0),
        NSColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0),
        NSColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0)
    ])
    
    let cupPath = NSBezierPath()
    cupPath.move(to: NSPoint(x: cupX, y: cupBottom))
    cupPath.line(to: NSPoint(x: (size - cupTopWidth) / 2, y: cupTop))
    cupPath.line(to: NSPoint(x: (size + cupTopWidth) / 2, y: cupTop))
    cupPath.line(to: NSPoint(x: cupX + cupBottomWidth, y: cupBottom))
    cupPath.close()
    cupGradient?.draw(in: cupPath, angle: 110)
    
    // Cup rim
    let rimOvalPath = NSBezierPath(ovalIn: NSRect(
        x: (size - cupTopWidth) / 2,
        y: cupTop - cupTopWidth * 0.1,
        width: cupTopWidth,
        height: cupTopWidth * 0.2
    ))
    NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0).setFill()
    rimOvalPath.fill()
    
    // Coffee inside
    let coffeeGradient = NSGradient(colors: [
        NSColor(red: 0.25, green: 0.15, blue: 0.05, alpha: 1.0),
        NSColor(red: 0.35, green: 0.22, blue: 0.10, alpha: 1.0),
        NSColor(red: 0.40, green: 0.26, blue: 0.12, alpha: 1.0)
    ])
    let coffeePath = NSBezierPath(ovalIn: NSRect(
        x: (size - cupTopWidth) / 2 + cupTopWidth * 0.05,
        y: cupTop - cupTopWidth * 0.08,
        width: cupTopWidth * 0.9,
        height: cupTopWidth * 0.16
    ))
    coffeeGradient?.draw(in: coffeePath, angle: 90)
    
    // Coffee foam/crema
    let foamPath = NSBezierPath(ovalIn: NSRect(
        x: (size - cupTopWidth) / 2 + cupTopWidth * 0.15,
        y: cupTop - cupTopWidth * 0.06,
        width: cupTopWidth * 0.7,
        height: cupTopWidth * 0.12
    ))
    NSColor(red: 0.76, green: 0.60, blue: 0.42, alpha: 0.6).setFill()
    foamPath.fill()
    
    // Handle
    let handlePath = NSBezierPath()
    let handleStart = NSPoint(x: (size + cupTopWidth) / 2 - 2 * scale, y: cupTop - cupHeight * 0.2)
    let handleEnd = NSPoint(x: cupX + cupBottomWidth, y: cupBottom + cupHeight * 0.3)
    let handleControl1 = NSPoint(x: size * 0.78, y: cupTop - cupHeight * 0.1)
    let handleControl2 = NSPoint(x: size * 0.80, y: cupBottom + cupHeight * 0.2)
    
    handlePath.move(to: handleStart)
    handlePath.curve(to: handleEnd, controlPoint1: handleControl1, controlPoint2: handleControl2)
    handlePath.lineWidth = 6.0 * scale
    handlePath.lineCapStyle = .round
    
    // Handle gradient effect
    NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0).setStroke()
    handlePath.stroke()
    
    // Handle highlight
    handlePath.lineWidth = 3.0 * scale
    NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.8).setStroke()
    handlePath.stroke()
    
    // Steam effect
    for i in 0..<3 {
        let steamPath = NSBezierPath()
        let xOffset = size * (0.4 + CGFloat(i) * 0.1)
        let yStart = cupTop + 2 * scale
        
        steamPath.move(to: NSPoint(x: xOffset, y: yStart))
        
        // Create wavy steam
        let cp1 = NSPoint(x: xOffset - size * 0.02, y: yStart + size * 0.08)
        let cp2 = NSPoint(x: xOffset + size * 0.02, y: yStart + size * 0.16)
        let end = NSPoint(x: xOffset - size * 0.01, y: yStart + size * 0.24)
        
        steamPath.curve(to: end, controlPoint1: cp1, controlPoint2: cp2)
        
        steamPath.lineWidth = 2.0 * scale
        steamPath.lineCapStyle = .round
        NSColor(white: 1.0, alpha: 0.3 - CGFloat(i) * 0.05).setStroke()
        steamPath.stroke()
    }
    
    // Subtle highlight on cup
    let highlightPath = NSBezierPath()
    highlightPath.move(to: NSPoint(x: cupX + cupBottomWidth * 0.2, y: cupBottom + cupHeight * 0.1))
    highlightPath.line(to: NSPoint(x: (size - cupTopWidth) / 2 + cupTopWidth * 0.2, y: cupTop - cupHeight * 0.1))
    highlightPath.lineWidth = 3.0 * scale
    NSColor(white: 1.0, alpha: 0.3).setStroke()
    highlightPath.stroke()
    
    image.unlockFocus()
    
    return image
}

// Generate iconset
let iconsetPath = "Caffeine.iconset"
try? FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

let sizes: [(Int, Int)] = [
    (16, 1), (16, 2),
    (32, 1), (32, 2),
    (128, 1), (128, 2),
    (256, 1), (256, 2),
    (512, 1), (512, 2)
]

print("🎨 Creating realistic coffee cup icon...")

for (baseSize, scale) in sizes {
    let actualSize = baseSize * scale
    let suffix = scale > 1 ? "@\(scale)x" : ""
    let filename = "icon_\(baseSize)x\(baseSize)\(suffix).png"
    let filepath = "\(iconsetPath)/\(filename)"
    
    if let icon = createRealisticCoffeeIcon(size: CGFloat(actualSize)) {
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
task.arguments = ["-c", "icns", iconsetPath, "-o", "Caffeine.app/Contents/Resources/AppIcon.icns"]
task.launch()
task.waitUntilExit()

// Clean up
try? FileManager.default.removeItem(atPath: iconsetPath)

// Refresh
let refreshTask = Process()
refreshTask.launchPath = "/usr/bin/touch"
refreshTask.arguments = ["Caffeine.app"]
refreshTask.launch()
refreshTask.waitUntilExit()

print("\n✅ Realistic coffee icon created!")
print("☕ The app now has a beautiful, realistic coffee cup icon!")