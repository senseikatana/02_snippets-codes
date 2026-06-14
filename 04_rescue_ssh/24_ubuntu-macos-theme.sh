#!/bin/bash

# ==============================================================================
# macOS-Style Customization Script for Ubuntu Cinnamon
# Theme: WhiteSur GTK + Icons + Plank Dock + Rofi Spotlight
# Based on vinceliuice's WhiteSur repositories
# ==============================================================================

set -e

echo "==> Starting macOS-style transformation..."

# ------------------------------------------------------------------------------
# 1. INSTALL DEPENDENCIES
# ------------------------------------------------------------------------------
echo "[1/6] Installing required tools (Plank, Rofi, Git, Gsettings)..."
sudo apt update
sudo apt install -y git plank rofi gtk2-engines-murrine gtk2-engines-pixbuf sassc libglib2.0-dev-bin

# ------------------------------------------------------------------------------
# 2. DOWNLOAD AND INSTALL WHITEsur GTK THEME
# ------------------------------------------------------------------------------
echo "[2/6] Downloading and installing WhiteSur GTK Theme (Official)..."

TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Clone the official repository
if [ ! -d "WhiteSur-gtk-theme" ]; then
    git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
fi

cd WhiteSur-gtk-theme

# Install the theme
# -c Light/Dark: Color scheme
# -t default: Theme variant
# --tweaks round: macOS-style rounded corners
echo "   -> Applying GTK theme..."
./install.sh -c Light -t default --tweaks round -d "$HOME/.themes"

# Install theme for GDM (login screen) - Optional, requires sudo
# sudo ./install.sh -g

# ------------------------------------------------------------------------------
# 3. DOWNLOAD AND INSTALL WHITEsur ICON THEME
# ------------------------------------------------------------------------------
echo "[3/6] Downloading and installing WhiteSur Icon Theme..."

cd "$TEMP_DIR"
if [ ! -d "WhiteSur-icon-theme" ]; then
    git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1
fi

cd WhiteSur-icon-theme
echo "   -> Applying icons..."
./install.sh -d "$HOME/.icons"

# ------------------------------------------------------------------------------
# 4. CONFIGURE ROFI (SPOTLIGHT SEARCH)
# ------------------------------------------------------------------------------
echo "[4/6] Configuring Rofi as Spotlight..."

mkdir -p "$HOME/.config/rofi"

# Create Spotlight-style Rofi configuration
cat <<EOF > "$HOME/.config/rofi/spotlight.rasi"
configuration {
    modi: "drun,run";
    show-icons: true;
    drun-display-format: "{name}";
    disable-history: false;
    sidebar-mode: false;
    location: center;
    yoffset: -200; /* Slightly raise to center on large screens */
}

* {
    background-color: #F5F5F500; /* Transparent background for Compiz blur */
    text-color: #000000;
    font: "SF Pro Display 12";
}

window {
    transparency: "real";
    background-color: #ffffffee; /* Semi-transparent white */
    border-radius: 12px;
    border: 1px;
    border-color: #dfdfdf;
    padding: 20px;
    width: 600px;
}

mainbox {
    children: [ inputbar, listview ];
    spacing: 10px;
}

inputbar {
    background-color: #ffffff00;
    border: 0 0 1px 0;
    border-color: #d0d0d0;
    children: [ prompt, entry ];
    padding: 5px;
}

prompt {
    text-color: #0066cc;
    margin: 0px 0.5em 0em 0em;
}

entry {
    text-color: #000000;
    placeholder: "Search...";
    placeholder-color: #999999;
}

listview {
    spacing: 5px;
    lines: 8;
    columns: 1;
    scrollbar: false;
    border: 0;
}

element {
    padding: 10px;
    border-radius: 8px;
}

element selected {
    background-color: #0066cc;
    text-color: #ffffff;
}

element-icon {
    size: 2em;
    vertical-align: 0.5;
    margin: 0px 10px 0px 0px;
}

element-text {
    vertical-align: 0.5;
}
EOF

# Configure the Rofi launcher desktop entry
cat <<EOF > "$HOME/.local/share/applications/spotlight.desktop"
[Desktop Entry]
Name=Spotlight Search
Comment=Run Rofi
Exec=rofi -show drun -theme spotlight
Icon=search
Terminal=false
Type=Application
Categories=Utility;
EOF

chmod +x "$HOME/.local/share/applications/spotlight.desktop"

# ------------------------------------------------------------------------------
# 5. CONFIGURE PLANK DOCK
# ------------------------------------------------------------------------------
echo "[5/6] Configuring Plank Dock..."

mkdir -p "$HOME/.config/plank/theme"

# Simple transparent theme for Plank
cat <<EOF > "$HOME/.config/plank/theme/dock.theme"
[PlankTheme]
TopRoundness=10
BottomRoundness=10
BorderColor=200,200,200
ItemPadding=3
FillColor=255,255,255,180
InnerPadding=5
EOF

# Initial Plank configuration
mkdir -p "$HOME/.config/"
if [ ! -f "$HOME/.config/plank/dock1/settings" ]; then
    mkdir -p "$HOME/.config/plank/dock1"
    cat <<EOF > "$HOME/.config/plank/dock1/settings"
[PlankDockPreferences]
Theme=Transparent
IconSize=48
HideMode=3
Alignment=center
Position=bottom
Pinned=firefox;org.gnome.Nautilus;code;vlc;org.telegram.desktop;spotify;
EOF
fi

# Add Plank to autostart
mkdir -p "$HOME/.config/autostart"
cp /usr/share/applications/plank.desktop "$HOME/.config/autostart/" 2>/dev/null || echo "Autostart already configured or not found."

# ------------------------------------------------------------------------------
# 6. APPLY CINNAMON SETTINGS (GSETTINGS)
# ------------------------------------------------------------------------------
echo "[6/6] Applying system changes (Cinnamon)..."

# Apply GTK theme
gsettings set org.cinnamon.desktop.interface gtk-theme 'WhiteSur-Light'

# Apply icon theme
gsettings set org.cinnamon.desktop.interface icon-theme 'WhiteSur'

# Apply window theme (Metacity)
gsettings set org.cinnamon.desktop.wm.preferences theme 'WhiteSur-Light'

# Apply cursor theme
gsettings set org.cinnamon.desktop.interface cursor-theme 'WhiteSur-cursors'

# Restart Cinnamon to apply visual changes immediately
echo "   -> Restarting Cinnamon to apply changes..."
cinnamon --replace &

echo "================================================================"
echo " CUSTOMIZATION COMPLETE "
echo "================================================================"
echo "1. WhiteSur theme has been installed."
echo "2. Plank Dock is configured at the bottom."
echo "3. Rofi is ready as Spotlight search."
echo ""
echo " FINAL MANUAL STEPS:"
echo " - Press 'Super' (Windows key), search for 'Startup Applications', and ensure 'Plank' is enabled."
echo " - To make Rofi the main menu:"
echo "   1. Go to System Settings -> Keyboard -> Shortcuts."
echo "   2. Find the menu shortcut (Super)."
echo "   3. Change it to run: rofi -show drun -theme spotlight"
echo "================================================================"