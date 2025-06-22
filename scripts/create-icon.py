#!/usr/bin/env python3

import os
import subprocess
from PIL import Image, ImageDraw

def create_coffee_cup_icon(size, filled=False):
    """Create a simple coffee cup icon"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Scale factors
    scale = size / 100
    
    # Cup dimensions
    cup_width = int(60 * scale)
    cup_height = int(50 * scale)
    cup_x = (size - cup_width) // 2
    cup_y = (size - cup_height) // 2 + int(10 * scale)
    
    # Handle dimensions
    handle_width = int(20 * scale)
    handle_height = int(30 * scale)
    handle_x = cup_x + cup_width - int(5 * scale)
    handle_y = cup_y + int(10 * scale)
    
    # Saucer dimensions
    saucer_width = int(80 * scale)
    saucer_height = int(15 * scale)
    saucer_x = (size - saucer_width) // 2
    saucer_y = cup_y + cup_height - int(5 * scale)
    
    # Colors
    cup_color = (80, 80, 80, 255) if not filled else (60, 60, 60, 255)
    coffee_color = (101, 67, 33, 255)  # Brown for coffee
    saucer_color = (100, 100, 100, 255)
    
    # Draw saucer (ellipse)
    draw.ellipse([saucer_x, saucer_y, saucer_x + saucer_width, saucer_y + saucer_height], 
                 fill=saucer_color, outline=(60, 60, 60, 255), width=max(1, int(2 * scale)))
    
    # Draw cup
    draw.rectangle([cup_x, cup_y, cup_x + cup_width, cup_y + cup_height], 
                   fill=cup_color, outline=(40, 40, 40, 255), width=max(1, int(2 * scale)))
    
    # Draw handle
    draw.arc([handle_x, handle_y, handle_x + handle_width, handle_y + handle_height], 
             270, 90, fill=(60, 60, 60, 255), width=max(2, int(3 * scale)))
    
    # Draw coffee if filled
    if filled:
        coffee_margin = int(5 * scale)
        coffee_height = int(30 * scale)
        draw.rectangle([cup_x + coffee_margin, cup_y + coffee_margin,
                       cup_x + cup_width - coffee_margin, cup_y + coffee_height],
                       fill=coffee_color)
    
    return img

def create_iconset():
    """Create an iconset directory with all required icon sizes"""
    iconset_path = "Caffeine.iconset"
    os.makedirs(iconset_path, exist_ok=True)
    
    # Icon sizes for macOS
    sizes = [
        (16, 1), (16, 2),
        (32, 1), (32, 2),
        (128, 1), (128, 2),
        (256, 1), (256, 2),
        (512, 1), (512, 2)
    ]
    
    for base_size, scale in sizes:
        actual_size = base_size * scale
        suffix = f"@{scale}x" if scale > 1 else ""
        
        # Create regular icon (filled cup)
        icon = create_coffee_cup_icon(actual_size, filled=True)
        icon.save(f"{iconset_path}/icon_{base_size}x{base_size}{suffix}.png")
    
    return iconset_path

def convert_to_icns(iconset_path):
    """Convert iconset to .icns file"""
    output_path = "Caffeine.app/Contents/Resources/AppIcon.icns"
    
    # Ensure Resources directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    # Use iconutil to create .icns file
    subprocess.run(["iconutil", "-c", "icns", iconset_path, "-o", output_path])
    
    # Clean up iconset directory
    subprocess.run(["rm", "-rf", iconset_path])
    
    return output_path

def main():
    print("🎨 Creating app icon...")
    
    # Check if Pillow is installed
    try:
        from PIL import Image, ImageDraw
    except ImportError:
        print("❌ Pillow not installed. Installing...")
        subprocess.run(["pip3", "install", "Pillow"])
        from PIL import Image, ImageDraw
    
    # Create iconset
    iconset_path = create_iconset()
    print(f"✅ Created iconset: {iconset_path}")
    
    # Convert to .icns
    icns_path = convert_to_icns(iconset_path)
    print(f"✅ Created app icon: {icns_path}")
    
    print("🎉 App icon created successfully!")

if __name__ == "__main__":
    main()