#!/bin/bash

echo "🔐 Setting up passwordless caffeine mode..."
echo ""
echo "This script will configure your system to allow Caffeine to work without asking for password every time."
echo "You'll need to enter your administrator password once."
echo ""

# Create sudoers file for pmset
SUDOERS_FILE="/etc/sudoers.d/caffeine"
SUDOERS_CONTENT="%admin ALL=(ALL) NOPASSWD: /usr/bin/pmset -a disablesleep 0, /usr/bin/pmset -a disablesleep 1, /usr/bin/pmset sleepnow"

echo "Creating sudoers configuration..."
echo "$SUDOERS_CONTENT" | sudo tee "$SUDOERS_FILE" > /dev/null

# Set proper permissions
sudo chmod 0440 "$SUDOERS_FILE"

echo ""
echo "✅ Setup complete!"
echo ""
echo "Caffeine can now toggle sleep mode without asking for password."
echo ""
echo "To remove this configuration later, run:"
echo "  sudo rm $SUDOERS_FILE"