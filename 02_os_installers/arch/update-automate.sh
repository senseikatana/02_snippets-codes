#!/usr/bin/env zsh
#
# update-arch-automate.sh
# Automated update script for Arch Linux / Manjaro.
# Handles: system packages (pacman), AUR (yay), Snap, Flatpak,
#          orphan removal, and cache cleanup.
#
# Usage:
#   ./update-arch-automate.sh

# Print a colored header
echo "\e[1;34m=======================================================\e[0m"
echo "\e[1;34m  🚀 Full System Update (Arch/Manjaro) 🚀\e[0m"
echo "\e[1;34m=======================================================\e[0m\n"

echo "\e[1;36m🔵 1/4: Updating base system, kernel, drivers & AUR...\e[0m"

# Sync, update, and clean pacman cache
sudo pacman -Syu --noconfirm
sudo pacman -Sc --noconfirm

# Update AUR packages via yay
yay -Syu --noconfirm

echo "\n\e[1;32m🟢 2/4: Updating Snap packages...\e[0m"
sudo snap refresh

echo "\n\e[1;33m🟡 3/4: Updating Flatpak packages...\e[0m"
flatpak update -y

echo "\n\e[1;35m🟣 4/4: Removing orphan packages and cleaning cache...\e[0m"

# Collect orphaned dependencies (packages no longer required by any installed package)
orphans=($(pacman -Qtdq))

if (( ${#orphans[@]} > 0 )); then
    echo "Removing ${#orphans[@]} orphan package(s)..."
    sudo pacman -Rns --noconfirm "${orphans[@]}"
else
    echo "✅ No orphan packages found. System is clean."
fi

# Remove cached package tarballs, keeping only the last 2 versions per package
paccache -r

echo "\n\e[1;32m=======================================================\e[0m"
echo "\e[1;32m✨ Update completed successfully!\e[0m"
echo "\e[1;32m=======================================================\e[0m"