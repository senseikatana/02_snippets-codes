#!/usr/bin/env zsh
#
# update-deb-automate.sh
# Automated update script for Debian / Ubuntu.
# Handles: APT packages, Snap, Flatpak, orphan removal, and cache cleanup.
#
# Usage:
#   ./update-deb-automate.sh

# Print a colored header
echo "\e[1;34m=======================================================\e[0m"
echo "\e[1;34m  🚀 Full System Update (Debian/Ubuntu) 🚀\e[0m"
echo "\e[1;34m=======================================================\e[0m\n"

echo "\e[1;36m🔵 1/4: Updating repositories, base system & kernel...\e[0m"

# full-upgrade handles dependency changes and new kernel versions better than upgrade
sudo apt update && sudo apt full-upgrade -y

echo "\n\e[1;32m🟢 2/4: Updating Snap packages...\e[0m"
if command -v snap &> /dev/null; then
    sudo snap refresh
else
    echo "✅ Snap is not installed on this system. Skipping..."
fi

echo "\n\e[1;33m🟡 3/4: Updating Flatpak packages...\e[0m"
if command -v flatpak &> /dev/null; then
    flatpak update -y
else
    echo "✅ Flatpak is not installed on this system. Skipping..."
fi

echo "\n\e[1;35m🟣 4/4: Removing orphan dependencies and cleaning cache...\e[0m"

# autoremove removes packages that were auto-installed but no longer needed
# autoclean deletes obsolete package archives from the cache
sudo apt autoremove -y && sudo apt autoclean

echo "\n\e[1;32m=======================================================\e[0m"
echo "\e[1;32m✨ Update completed successfully!\e[0m"
echo "\e[1;32m=======================================================\e[0m"