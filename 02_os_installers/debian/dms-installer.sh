#!/usr/bin/env zsh

# ==============================================================================
# DANK MATERIAL SHELL INSTALLATION FOR DEBIAN 13 TRIXIE / UBUNTU
# Compatible with Niri and Hyprland - WITH INTERACTIVE PROMPTS
# ==============================================================================

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${CYAN}=== INSTALLING DANK MATERIAL SHELL (DMS) ===${NC}"
echo ""

# ==============================================================================
# INITIAL QUESTIONS
# ==============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Which components do you want to install?${NC}"
echo ""
echo -e "  1) ${GREEN}Full${NC} (DMS + Niri + Noctalia)"
echo -e "  2) ${CYAN}DMS only${NC} (no additional compositor)"
echo -e "  3) ${CYAN}DMS + Niri${NC} (without Noctalia)"
echo -e "  4) ${CYAN}DMS + Noctalia${NC} (without Niri - for Hyprland or other WM)"
echo -e "  5) ${YELLOW}Custom${NC} (choose each component)"
echo ""
read "INSTALL_TYPE?👉 Choose an option [1-5]: "

# ==============================================================================
# SET UP DANK LINUX REPOSITORIES (always)
# ==============================================================================
echo -e "\n${GREEN}[1/6] Setting up Dank Linux repositories...${NC}"

sudo mkdir -p /etc/apt/keyrings

# Detect distribution
DISTRO=$(lsb_release -is)
VERSION=$(lsb_release -cs)

if [[ "$DISTRO" == "Debian" ]] && [[ "$VERSION" == "trixie" || "$VERSION" == "13" ]]; then
    REPO_VERSION="Debian_13"
elif [[ "$DISTRO" == "Debian" ]] && [[ "$VERSION" == "bookworm" || "$VERSION" == "12" ]]; then
    REPO_VERSION="Debian_12"
elif [[ "$DISTRO" == "Ubuntu" ]]; then
    REPO_VERSION="xUbuntu_$(lsb_release -sr)"
else
    REPO_VERSION="Debian_13"
fi

echo -e "${YELLOW}   -> Using repositories for: $REPO_VERSION${NC}"

# DankLinux repository
if [ ! -f /etc/apt/sources.list.d/danklinux.list ]; then
    curl -fsSL https://download.opensuse.org/repositories/home:AvengeMedia:danklinux/$REPO_VERSION/Release.key | \
        sudo gpg --dearmor -o /etc/apt/keyrings/danklinux.gpg
    echo "deb [signed-by=/etc/apt/keyrings/danklinux.gpg] https://download.opensuse.org/repositories/home:/AvengeMedia:/danklinux/$REPO_VERSION/ /" | \
        sudo tee /etc/apt/sources.list.d/danklinux.list
fi

# DMS stable repository
if [ ! -f /etc/apt/sources.list.d/avengemedia-dms.list ]; then
    curl -fsSL https://download.opensuse.org/repositories/home:/AvengeMedia:/dms/$REPO_VERSION/Release.key | \
        sudo gpg --dearmor -o /etc/apt/keyrings/avengemedia-dms.gpg
    echo "deb [signed-by=/etc/apt/keyrings/avengemedia-dms.gpg] https://download.opensuse.org/repositories/home:/AvengeMedia:/dms/$REPO_VERSION/ /" | \
        sudo tee /etc/apt/sources.list.d/avengemedia-dms.list
fi

# ==============================================================================
# SYSTEM UPDATE
# ==============================================================================
echo -e "\n${GREEN}[2/6] Updating repositories...${NC}"
echo -e "${YELLOW}⚠️  This may take a few minutes...${NC}"
read "CONTINUE_UPDATE?👉 Update system packages? (S/n): "
if [[ "$CONTINUE_UPDATE" != "n" && "$CONTINUE_UPDATE" != "N" ]]; then
    sudo apt update
    read "DIST_UPGRADE?👉 Perform dist-upgrade? (s/N): "
    if [[ "$DIST_UPGRADE" == "s" || "$DIST_UPGRADE" == "S" ]]; then
        sudo apt dist-upgrade -y
    fi
    sudo apt autoremove -y
    sudo apt clean
fi

# ==============================================================================
# INSTALL DEPENDENCIES
# ==============================================================================
echo -e "\n${GREEN}[3/6] Installing dependencies...${NC}"
read "INSTALL_DEPS?👉 Install dependencies (Qt6, Wayland, etc.)? (S/n): "
if [[ "$INSTALL_DEPS" != "n" && "$INSTALL_DEPS" != "N" ]]; then
    sudo apt install -y -f curl wget git build-essential cmake ninja-build pkg-config
    
    sudo apt install -y -f \
        qt6-base-dev qt6-declarative-dev qt6-shadertools-dev qt6-wayland-dev \
        qt6-svg-dev qt6-tools-dev libwayland-dev wayland-protocols \
        libpam0g-dev libpolkit-agent-1-dev libpipewire-0.3-dev \
        libpango1.0-dev libcli11-dev libjemalloc-dev libseat-dev \
        libinput-dev libxkbcommon-dev libglib2.0-dev libgtk-3-dev \
        konsole kitty fuzzel wl-clipboard xdg-desktop-portal-gtk \
        xwayland qt6ct nwg-look
fi

# ==============================================================================
# INSTALL DMS
# ==============================================================================
echo -e "\n${GREEN}[4/6] Installing Dank Material Shell...${NC}"

# Ask for version
echo -e "${YELLOW}Which DMS version do you want to install?${NC}"
echo "  1) ${GREEN}Stable${NC} (recommended)"
echo "  2) ${CYAN}Development${NC} (nightly builds)"
echo "  3) ${RED}Both${NC} (stable + git)"
read "DMS_VERSION?👉 Choose [1-3]: "

case $DMS_VERSION in
    2)
        echo -e "${YELLOW}   -> Adding DMS development repository...${NC}"
        if [ ! -f /etc/apt/sources.list.d/avengemedia-dms-git.list ]; then
            curl -fsSL https://download.opensuse.org/repositories/home:/AvengeMedia:/dms-git/$REPO_VERSION/Release.key | \
                sudo gpg --dearmor -o /etc/apt/keyrings/avengemedia-dms-git.gpg
            echo "deb [signed-by=/etc/apt/keyrings/avengemedia-dms-git.gpg] https://download.opensuse.org/repositories/home:/AvengeMedia:/dms-git/$REPO_VERSION/ /" | \
                sudo tee /etc/apt/sources.list.d/avengemedia-dms-git.list
        fi
        sudo apt update
        sudo apt install -y dankmaterialshell dms-shell dgop dsearch matugen
        ;;
    3)
        # Both repositories
        if [ ! -f /etc/apt/sources.list.d/avengemedia-dms-git.list ]; then
            curl -fsSL https://download.opensuse.org/repositories/home:/AvengeMedia:/dms-git/$REPO_VERSION/Release.key | \
                sudo gpg --dearmor -o /etc/apt/keyrings/avengemedia-dms-git.gpg
            echo "deb [signed-by=/etc/apt/keyrings/avengemedia-dms-git.gpg] https://download.opensuse.org/repositories/home:/AvengeMedia:/dms-git/$REPO_VERSION/ /" | \
                sudo tee /etc/apt/sources.list.d/avengemedia-dms-git.list
        fi
        sudo apt update
        sudo apt install -y dankmaterialshell dms-shell dgop dsearch matugen
        ;;
    *)
        # Stable (default)
        sudo apt update
        sudo apt install -y dankmaterialshell dms-shell dgop dsearch matugen 2>/dev/null || {
            echo -e "${YELLOW}   -> Fallback: installing from official script...${NC}"
            curl -fsSL https://install.danklinux.com | sh
        }
        ;;
esac

# ==============================================================================
# INSTALL NIRI (optional)
# ==============================================================================
INSTALL_NIRI="n"
if [[ "$INSTALL_TYPE" == "1" || "$INSTALL_TYPE" == "3" || "$INSTALL_TYPE" == "5" ]]; then
    echo -e "\n${GREEN}[5/6] Niri Compositor...${NC}"
    read "INSTALL_NIRI?👉 Install Niri compositor? (s/N): "
fi

if [[ "$INSTALL_NIRI" == "s" || "$INSTALL_NIRI" == "S" ]]; then
    if ! command -v niri &> /dev/null; then
        echo -e "${YELLOW}   -> Installing Niri...${NC}"
        read "NIRI_METHOD?👉 From repository (R) or build from source (C)? [R/c]: "
        if [[ "$NIRI_METHOD" == "c" || "$NIRI_METHOD" == "C" ]]; then
            if ! command -v rustc &> /dev/null; then
                read "INSTALL_RUST?👉 Install Rust? (S/n): "
                if [[ "$INSTALL_RUST" != "n" && "$INSTALL_RUST" != "N" ]]; then
                    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                    source "$HOME/.cargo/env"
                fi
            fi
            git clone https://github.com/YaLTeR/niri.git /tmp/niri
            cd /tmp/niri
            cargo build --release
            sudo cp target/release/niri /usr/local/bin/
            sudo cp resources/niri-session /usr/local/bin/
            sudo cp resources/niri.desktop /usr/share/wayland-sessions/
            cd -
            rm -rf /tmp/niri
        else
            sudo apt install -y niri 2>/dev/null || {
                echo -e "${RED}   -> Niri not available in repositories${NC}"
            }
        fi
    else
        echo -e "${GREEN}   ✅ Niri is already installed: $(niri --version)${NC}"
    fi
fi

# ==============================================================================
# INSTALL NOCTALIA (optional)
# ==============================================================================
INSTALL_NOCTALIA="n"
if [[ "$INSTALL_TYPE" == "1" || "$INSTALL_TYPE" == "4" || "$INSTALL_TYPE" == "5" ]]; then
    echo -e "\n${GREEN}[6/6] Noctalia Shell...${NC}"
    read "INSTALL_NOCTALIA?👉 Install Noctalia Shell? (s/N): "
fi

if [[ "$INSTALL_NOCTALIA" == "s" || "$INSTALL_NOCTALIA" == "S" ]]; then
    if [ ! -d "/tmp/noctalia-qs" ]; then
        echo -e "${YELLOW}   -> Compiling Noctalia-QS...${NC}"
        git clone https://github.com/noctalia-dev/noctalia-qs.git /tmp/noctalia-qs
        cd /tmp/noctalia-qs
        read "BUILD_NOCTALIA?👉 Run build.sh? (S/n): "
        if [[ "$BUILD_NOCTALIA" != "n" && "$BUILD_NOCTALIA" != "N" ]]; then
            ./bin/build.sh
            sudo cmake --install build
        fi
        cd -
    fi
    
    if [ ! -d "$HOME/.config/quickshell/noctalia-shell" ]; then
        mkdir -p "$HOME/.config/quickshell"
        read "CLONE_NOCTALIA?👉 Clone Noctalia configuration? (S/n): "
        if [[ "$CLONE_NOCTALIA" != "n" && "$CLONE_NOCTALIA" != "N" ]]; then
            git clone https://github.com/noctalia-dev/noctalia-shell.git "$HOME/.config/quickshell/noctalia-shell"
        fi
    fi
fi

# ==============================================================================
# CONFIGURE NIRI (only if installed)
# ==============================================================================
if [[ "$INSTALL_NIRI" == "s" || "$INSTALL_NIRI" == "S" ]]; then
    echo -e "\n${GREEN}[7/7] Configuring Niri...${NC}"
    read "CONFIGURE_NIRI?👉 Configure Niri with DMS settings? (S/n): "
    if [[ "$CONFIGURE_NIRI" != "n" && "$CONFIGURE_NIRI" != "N" ]]; then
        mkdir -p ~/.config/niri
        
        if [ -f ~/.config/niri/config.kdl ]; then
            echo -e "${YELLOW}   -> config.kdl already exists. Add configuration? (s/N): "
            read "APPEND_CONFIG?"
            if [[ "$APPEND_CONFIG" == "s" || "$APPEND_CONFIG" == "S" ]]; then
                cat >> ~/.config/niri/config.kdl << 'EOF'

// Configuration for Dank Material Shell
window-rule {
  geometry-corner-radius 20
  clip-to-geometry true
}

binds {
  Mod+Space { dms-launcher; }
  Mod+Q { close-window; }
  Mod+F { fullscreen-window; }
}
EOF
            fi
        else
            cat > ~/.config/niri/config.kdl << 'EOF'
// Niri configuration for Dank Material Shell
window-rule {
  geometry-corner-radius 20
  clip-to-geometry true
}

binds {
  Mod+Space { dms-launcher; }
  Mod+Q { close-window; }
  Mod+F { fullscreen-window; }
  
  Mod+1 { focus-workspace 1; }
  Mod+2 { focus-workspace 2; }
  Mod+3 { focus-workspace 3; }
  Mod+4 { focus-workspace 4; }
}
EOF
            echo -e "${GREEN}   ✅ Configuration created at ~/.config/niri/config.kdl${NC}"
        fi
    fi
fi

# ==============================================================================
# FINALIZATION
# ==============================================================================
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ INSTALLATION COMPLETE${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if command -v dms &> /dev/null; then
    echo -e "${YELLOW}📝 NEXT STEPS FOR DMS:${NC}"
    echo "   ${CYAN}dms setup${NC}              - Full initial setup"
    echo "   ${CYAN}dms setup binds${NC}        - Only configure keyboard shortcuts"
    echo "   ${CYAN}dms --help${NC}              - See all commands"
    echo ""
fi

if [[ "$INSTALL_NIRI" == "s" || "$INSTALL_NIRI" == "S" ]]; then
    echo -e "${YELLOW}🚀 TO USE NIRI:${NC}"
    echo "   - Log out and select 'Niri' in the session manager"
    echo "   - Or run: ${CYAN}niri${NC} from a TTY"
    echo ""
fi

if [[ "$INSTALL_NOCTALIA" == "s" || "$INSTALL_NOCTALIA" == "S" ]]; then
    echo -e "${YELLOW}🎨 TO USE NOCTALIA:${NC}"
    echo "   ${CYAN}qs -c noctalia-shell${NC}    - Launch Noctalia with Quickshell"
    echo ""
fi

echo -e "${BLUE}💡 TIP:${NC} You can re-run this script to install missing components"
echo ""
