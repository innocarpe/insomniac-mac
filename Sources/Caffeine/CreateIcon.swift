import AppKit

struct IconCreator {
    static func createIcon() {
        let sizes = [16, 32, 128, 256, 512]
        let scales = [1, 2]
        
        let iconsetPath = "Caffeine.iconset"
        try? FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)
        
        for size in sizes {
            for scale in scales {
                let actualSize = size * scale
                let filename = scale == 1 ? "icon_\(size)x\(size).png" : "icon_\(size)x\(size)@2x.png"
                let filepath = "\(iconsetPath)/\(filename)"
                
                if let image = createCoffeeIcon(size: CGFloat(actualSize)) {
                    if let tiffData = image.tiffRepresentation,
                       let bitmap = NSBitmapImageRep(data: tiffData),
                       let pngData = bitmap.representation(using: .png, properties: [:]) {
                        try? pngData.write(to: URL(fileURLWithPath: filepath))
                    }
                }
            }
        }
        
        // Convert to icns
        let task = Process()
        task.launchPath = "/usr/bin/iconutil"
        task.arguments = ["-c", "icns", iconsetPath, "-o", "AppIcon.icns"]
        task.launch()
        task.waitUntilExit()
        
        print("Icon created: AppIcon.icns")
    }
    
    static func createCoffeeIcon(size: CGFloat) -> NSImage? {
        let image = NSImage(size: NSSize(width: size, height: size))
        
        image.lockFocus()
        
        // Background
        let background = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: size, height: size), 
                                     xRadius: size * 0.2, yRadius: size * 0.2)
        NSColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0).setFill()
        background.fill()
        
        // Coffee cup emoji
        let fontSize = size * 0.65
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: fontSize),
            .foregroundColor: NSColor(red: 0.83, green: 0.65, blue: 0.45, alpha: 1.0)
        ]
        
        let text = "☕"
        let textSize = text.size(withAttributes: attributes)
        let textRect = NSRect(x: (size - textSize.width) / 2,
                             y: (size - textSize.height) / 2,
                             width: textSize.width,
                             height: textSize.height)
        
        text.draw(in: textRect, withAttributes: attributes)
        
        image.unlockFocus()
        
        return image
    }
}