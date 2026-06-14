#!/usr/bin/env zsh

# ==============================================================================
# POST-INSTALLATION SCRIPT FOR DEBIAN / UBUNTU / LINUX MINT
# Migrating from Arch Linux / KDE Plasma to Cinnamon/GNOME
# ==============================================================================

set -e

# COLORS
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}=== STARTING DEBIAN/UBUNTU SETUP ===${NC}"

# ------------------------------------------------------------------------------
# 1. SYSTEM UPDATE AND BASIC DEPENDENCIES
# ------------------------------------------------------------------------------
echo -e "${GREEN}[1/8] Updating system and installing basic dependencies...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget gnupg2 lsb-release ca-certificates software-properties-common apt-transport-https build-essential unzip

# ------------------------------------------------------------------------------
# 2. EXTERNAL REPOSITORY SETUP
# ------------------------------------------------------------------------------
echo -e "${GREEN}[2/8] Adding external repositories...${NC}"

# --- Brave Browser ---
if [ ! -f /etc/apt/sources.list.d/brave-browser-release.list ]; then
    echo -e "${YELLOW}   -> Setting up Brave Browser...${NC}"
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
fi

# --- VS Code ---
if [ ! -f /etc/apt/sources.list.d/vscode.list ]; then
    echo -e "${YELLOW}   -> Setting up Visual Studio Code...${NC}"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg > /dev/null
    echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
fi

# --- Mullvad VPN ---
if [ ! -f /etc/apt/sources.list.d/mullvad.list ]; then
    echo -e "${YELLOW}   -> Setting up Mullvad VPN...${NC}"
    curl -fsSL https://repository.mullvad.net/deb/mullvad-keyring.asc | sudo tee /usr/share/keyrings/mullvad-keyring.asc > /dev/null
    echo "deb [signed-by=/mullvad-keyring.asc arch=amd64] https://repository.mullvad.net/deb/stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mullvad.list
fi

# --- Librewolf ---
if [ ! -f /etc/apt/sources.list.d/librewolf.sources ]; then
    echo -e "${YELLOW}   -> Setting up Librewolf...${NC}"
    DISTRO=$(lsb_release -cs)
    sudo curl -fsSL https://deb.librewolf.net/keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/librewolf-keyring.gpg
    echo "Types: deb
URIs: https://deb.librewolf.net
Suites: $DISTRO
Components: main
Signed-By: /usr/share/keyrings/librewolf-keyring.gpg" | sudo tee /etc/apt/sources.list.d/librewolf.sources > /dev/null
fi

# --- Fastfetch (PPA) ---
if ! dpkg -l | grep -q fastfetch; then
    echo -e "${YELLOW}   -> Setting up Fastfetch PPA...${NC}"
    sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
fi

# --- Btop (Official repository) ---
# Already in official repositories

# Update package list
sudo apt update

# ------------------------------------------------------------------------------
# 3. NATIVE PACKAGE INSTALLATION (APT)
# ------------------------------------------------------------------------------
echo -e "${GREEN}[3/8] Installing native packages...${NC}"

# Complete package list
PACKAGES=(
    # System and Development
    git cmake make curl wget neovim build-essential
    python3-pip python3-venv perl
    
    # Editors and Office
    code gedit
    
    # Browsers
    brave-browser librewolf
    
    # VPN
    mullvad-vpn wireguard-tools
    
    # Multimedia
    vlc obs-studio audacity kdenlive mpv ffmpeg
    gimp inkscape krita gwenview
    
    # Utilities
    gparted htop btop fastfetch zoxide keepassxc
    kdeconnect brightnessctl timeshift filezilla
    
    # Shell
    zsh
)

sudo apt install -y "${PACKAGES[@]}"

# ------------------------------------------------------------------------------
# 4. FLATPAK INSTALLATION
# ------------------------------------------------------------------------------
echo -e "${GREEN}[4/8] Installing Flatpak applications...${NC}"

# Install Flatpak if not present
if ! command -v flatpak &> /dev/null; then
    sudo apt install -y flatpak
fi

# Add Flathub
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Flatpak list (equivalent to your Arch list)
FLATPAKS=(
    # Internet and Communication
    org.signal.Signal
    org.telegram.desktop
    org.onlyoffice.desktopeditors
    com.usebruno.Bruno          # Postman alternative
    org.mozilla.Thunderbird     # If you prefer Flatpak
    
    # Multimedia and Graphics
    net.scribus.Scribus         # converseen alternative
    org.kde.kdenlive
    org.tenacityaudio.Tenacity  # Audacity fork
    
    # Utilities
    it.mijorus.gearlever        # AppImage manager
    org.localsend.localsend_app # PairDrop alternative
    org.kde.isoimagewriter
    io.github.hyfetch.hyfetch
    app.fotema.Fotema           # Photo viewer
    org.kde.yakuake             # Dropdown terminal
)

flatpak install -y flathub "${FLATPAKS[@]}"

# ------------------------------------------------------------------------------
# 5. APPIMAGES
# ------------------------------------------------------------------------------
echo -e "${GREEN}[5/8] Setting up AppImages...${NC}"

mkdir -p "$HOME/Applications"

# Obsidian
if [ ! -f "$HOME/Applications/Obsidian.AppImage" ]; then
    echo -e "${YELLOW}   -> Downloading Obsidian...${NC}"
    OBSIDIAN_URL=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep "browser_download_url.*AppImage" | head -n 1 | cut -d '"' -f 4)
    wget -q "$OBSIDIAN_URL" -O "$HOME/Applications/Obsidian.AppImage"
    chmod +x "$HOME/Applications/Obsidian.AppImage"
fi

# LM Studio
if [ ! -f "$HOME/Applications/LM_Studio.AppImage" ]; then
    echo -e "${YELLOW}   -> Downloading LM Studio...${NC}"
    LM_URL=$(curl -s https://api.github.com/repos/lmstudio-ai/lms-desktop/releases/latest | grep "browser_download_url.*x86_64.AppImage" | head -n 1 | cut -d '"' -f 4)
    if [ -n "$LM_URL" ]; then
        wget -q "$LM_URL" -O "$HOME/Applications/LM_Studio.AppImage"
        chmod +x "$HOME/Applications/LM_Studio.AppImage"
    else
        echo -e "${YELLOW}   [!] LM Studio could not be downloaded. Visit: https://lmstudio.ai${NC}"
    fi
fi

# ------------------------------------------------------------------------------
# 6. ADDITIONAL PACKAGES VIA PIP/SCRIPT
# ------------------------------------------------------------------------------
echo -e "${GREEN}[6/8] Installing additional tools...${NC}"

# Install Hyfetch (neofetch alternative)
if ! command -v hyfetch &> /dev/null; then
    pip3 install --user hyfetch
fi

# ------------------------------------------------------------------------------
# 7. ZSH AND OH-MY-ZSH SETUP
# ------------------------------------------------------------------------------
echo -e "${GREEN}[7/8] Setting up Zsh...${NC}"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}   -> Installing Oh My Zsh...${NC}"
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Useful Zsh plugins
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# ------------------------------------------------------------------------------
# 8. CLEANUP AND FINALIZATION
# ------------------------------------------------------------------------------
echo -e "${GREEN}[8/8] Final cleanup...${NC}"
sudo apt autoremove -y
sudo apt clean

echo ""
echo -e "${CYAN}=== INSTALLATION COMPLETE ===${NC}"
echo ""
echo -e "${GREEN}📋 INSTALLED APPLICATIONS SUMMARY:${NC}"
echo "✓ Browsers: Brave, Librewolf"
echo "✓ VPN: Mullvad"
echo "✓ Development: VS Code, Git, CMake, Python"
echo "✓ Multimedia: VLC, OBS Studio, Kdenlive, Audacity/Tenacity"
echo "✓ Graphics: GIMP, Inkscape, Krita"
echo "✓ Office: OnlyOffice (Flatpak)"
echo "✓ Utilities: Btop, Fastfetch, Timeshift, KeePassXC"
echo ""
echo -e "${YELLOW}⚠️  PENDING ACTIONS:${NC}"
echo "1. Change your default shell: ${CYAN}chsh -s \$(which zsh)${NC}"
echo "2. Configure Zsh by editing: ${CYAN}nano ~/.zshrc${NC}"
echo "3. AppImages in: ${CYAN}~/Applications${NC}"
echo "4. Use ${CYAN}Gear Lever${NC} to integrate AppImages into the system"
echo "5. Configure Timeshift for system backups"
echo "6. Review firewall configuration: ${CYAN}sudo ufw enable${NC}"
echo ""
echo -e "${GREEN}✅ System ready to use!${NC}"
