#!/usr/bin/env zsh

# ==============================================================================
# POST-INSTALLATION SCRIPT FOR ARCH LINUX / MANJARO / BIGLINUX
# Complete package installation and configuration
# ==============================================================================

# TERMINAL COLORS
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${CYAN}=== STARTING ARCH LINUX CONFIGURATION ===${NC}"

# ------------------------------------------------------------------------------
# 1. UPDATE THE SYSTEM
# ------------------------------------------------------------------------------
echo -e "${GREEN}[1/6] Updating the system...${NC}"
sudo pacman -Syu --noconfirm

# ------------------------------------------------------------------------------
# 2. INSTALL OFFICIAL PACKAGES (PACMAN)
# ------------------------------------------------------------------------------
echo -e "${GREEN}[2/6] Installing packages from official repositories...${NC}"

PACMAN_PACKAGES=(
    # System and development tools
    git make cmake perl wget curl gparted
    base-devel python python-pip
    
    # Editors and IDEs
    micro neovim cursor-editor
    
    # Browsers
    brave mullvad-browser mullvad-vpn
    
    # Multimedia and Graphics
    audacity kdenlive obs-studio inkscape krita gwenview 
    vlc mpv ffmpeg gimp
    
    # Office and Utilities
    libreoffice-fresh keepassxc
    
    # System and Network
    wireguard-tools timeshift htop nvtop fastfetch
    zoxide zsh eza lolcat zinit bat
    
    # KDE Connect (for Android integration)
    kdeconnect
)

sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

# ------------------------------------------------------------------------------
# 3. INSTALL AUR HELPER (YAY)
# ------------------------------------------------------------------------------
if ! command -v yay &> /dev/null; then
    echo -e "${GREEN}[3/6] Installing YAY (AUR helper)...${NC}"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi

# ------------------------------------------------------------------------------
# 4. INSTALL AUR PACKAGES (WITH YAY)
# ------------------------------------------------------------------------------
echo -e "${GREEN}[4/6] Installing AUR packages with YAY...${NC}"

AUR_PACKAGES=(
    librewolf-bin
    localsend-bin
    onlyoffice-bin
    tenacity-git
    obsidian-appimage
    lm-studio-appimage
    hyfetch
)

yay -Syu --noconfirm --needed "${AUR_PACKAGES[@]}"

# ------------------------------------------------------------------------------
# 5. POST-INSTALLATION CONFIGURATION
# ------------------------------------------------------------------------------
echo -e "${GREEN}[5/6] Configuring environment...${NC}"


# Clone wallpapers
# if [ ! -d "$HOME/Pictures/wallpaper" ]; then
#     echo -e "${YELLOW}   -> Downloading wallpapers...${NC}"
#     git clone https://github.com/mylinuxforwork/wallpaper.git "$HOME/Pictures/wallpaper"
# fi


# ------------------------------------------------------------------------------
# 6. FINALIZATION
# ------------------------------------------------------------------------------
echo -e "${GREEN}[6/6] Cleanup and finalization...${NC}"
sudo pacman -Scc --noconfirm

echo ""
echo -e "${CYAN}=== INSTALLATION COMPLETED ON ARCH LINUX ===${NC}"
echo ""
echo -e "${GREEN}📋 INSTALLED PACKAGES:${NC}"
echo "✓ System: git, cmake, python, base-devel"
echo "✓ Browsers: Brave, Firefox, Librewolf, Mullvad Browser"
echo "✓ VPN: Mullvad VPN, Wireguard"
echo "✓ Development: VS Code, Neovim, Kdevelop"
echo "✓ Multimedia: VLC, OBS Studio, Kdenlive, Audacity/Tenacity"
echo "✓ Graphics: GIMP, Inkscape, Krita, Luminance HDR"
echo "✓ Office: LibreOffice, OnlyOffice"
echo "✓ Utilities: Btop, Fastfetch, Timeshift, KeePassXC, LocalSend"
echo ""
echo -e "${YELLOW}⚠️  NEXT STEPS:${NC}"
echo "1. Change default shell: ${CYAN}chsh -s \$(which zsh)${NC}"
echo "2. Reboot to apply all changes"
echo "3. Configure Mullvad VPN: ${CYAN}mullvad account login${NC}"
echo "4. For Hyprland: edit ${CYAN}~/.config/hypr/hyprland.conf${NC}"
echo ""
