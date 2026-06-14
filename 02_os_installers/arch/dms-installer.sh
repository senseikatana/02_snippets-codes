#!/usr/bin/env zsh

# ==============================================================================
# DANK MATERIAL SHELL INSTALLER FOR ARCH LINUX
# Compatible with Niri and Hyprland
# ==============================================================================

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}=== INSTALLING DANK MATERIAL SHELL FOR ARCH LINUX ===${NC}"

# ------------------------------------------------------------------------------
# 1. INSTALL DANK MATERIAL SHELL (DMS)
# ------------------------------------------------------------------------------
echo -e "${GREEN}[1/4] Installing Dank Material Shell...${NC}"
curl -fsSL https://install.danklinux.com | sh

# ------------------------------------------------------------------------------
# 2. INSTALL DMS SHELL FOR NIRI
# ------------------------------------------------------------------------------
echo -e "${GREEN}[2/4] Installing DMS Shell for Niri...${NC}"

# Detect whether we use paru or yay
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
else
    echo -e "${YELLOW}[!] Neither paru nor yay found. Installing paru...${NC}"
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
    AUR_HELPER="paru"
fi

echo -e "${YELLOW}   -> Installing packages with $AUR_HELPER...${NC}"
$AUR_HELPER -S --noconfirm dms-shell-niri
$AUR_HELPER -S --noconfirm dgop dsearch matugen wl-clipboard

# ------------------------------------------------------------------------------
# 3. INSTALL NOCTALIA SHELL
# ------------------------------------------------------------------------------
echo -e "${GREEN}[3/4] Installing Noctalia Shell...${NC}"
$AUR_HELPER -S --noconfirm noctalia-shell
# Development version (optional)
# $AUR_HELPER -S --noconfirm noctalia-shell-git

# ------------------------------------------------------------------------------
# 4. CONFIGURE NIRI
# ------------------------------------------------------------------------------
echo -e "${GREEN}[4/4] Configuring Niri...${NC}"

# Create config directory if it doesn't exist
mkdir -p ~/.config/niri

# Add rounded corners and debug configuration
if [ -f ~/.config/niri/config.kdl ]; then
    echo -e "${YELLOW}   -> Adding window rules to existing config.kdl...${NC}"
    
    # Check if configuration already exists
    if ! grep -q "geometry-corner-radius" ~/.config/niri/config.kdl; then
        cat >> ~/.config/niri/config.kdl << 'EOF'

# Configuration added by DMS installer
window-rule {
  // Rounded corners for a modern look.
  geometry-corner-radius 20

  // Clips window contents to the rounded corner boundaries.
  clip-to-geometry true
}

debug {
  // Allows notification actions and window activation from Noctalia.
  honor-xdg-activation-with-invalid-serial
}
EOF
    fi
else
    echo -e "${YELLOW}   -> Creating new config.kdl...${NC}"
    cat > ~/.config/niri/config.kdl << 'EOF'
// Niri configuration for Dank Material Shell
window-rule {
  // Rounded corners for a modern look.
  geometry-corner-radius 20

  // Clips window contents to the rounded corner boundaries.
  clip-to-geometry true
}

debug {
  // Allows notification actions and window activation from Noctalia.
  honor-xdg-activation-with-invalid-serial
}
EOF
fi

echo ""
echo -e "${CYAN}=== INSTALLATION COMPLETED ===${NC}"
echo ""
echo -e "${GREEN}✅ DANK MATERIAL SHELL INSTALLED SUCCESSFULLY${NC}"
echo ""
echo -e "${YELLOW}📝 NEXT STEPS:${NC}"
echo "1. If this is your first installation, run: ${CYAN}dms setup${NC}"
echo "2. To configure only keybindings: ${CYAN}dms setup binds${NC}"
echo "3. To configure colors: ${CYAN}dms setup colors${NC}"
echo "4. Restart your Wayland session to apply changes"
echo ""
echo -e "${YELLOW}💡 TIP:${NC} Dank Material Shell replaces multiple components:"
echo "   • waybar → DMS Bar"
echo "   • swaylock → DMS Lock"
echo "   • mako → DMS Notifications"
echo "   • fuzzel → DMS Launcher"
echo ""
