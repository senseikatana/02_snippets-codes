https://soploslinux.com/manjaro-25-0-1-guia-completa-de-instalacion/

### Only for KDE DW Version: 

- Cambiar de mirror al más cercano.
sudo pacman-mirrors --geoip
sudo pamac update --force-refresh

- Librerías Indispensables
sudo pacman -Sy base-devel

- Compresores
sudo pacman -S xz bzip2 p7zip lbzip2 lrzip arj lzop cpio unrar

- Códecs
sudo pacman -S jasper lame libdca libdv gst-libav libtheora libvorbis libxv wavpack x264 xvidcore dvd+rw-tools dvdauthor dvgrab libmad libmpeg2 libdvdcss libdvdread libdvdnav exfat-utils fuse-exfat a52dec faac faad2 flac

- Aur
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

- Flatpak
sudo pacman -S flatpak
pamac install flatpak libpamac-flatpak-plugin

- Snap
sudo pacman -S snapd
sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap
pamac install libpamac-snap-plugin
sudo systemctl enable --now snapd.apparmor  

yay -S yaru-colors-gtk-theme 
yay -S yaru-colors-icon-theme 
yay -S yaru-sound-theme  
yay -S ttf-ms-fonts  
yay -S ttf-ubuntu-font-family

- Iconos de Escritorio

nano ~/Escritorio/home.desktop
[Desktop Entry]
Type=Application
Name=Carpeta Personal
Comment=Abrir tu carpeta personal
Exec=dolphin ~
Icon=system-file-manager
Terminal=false
Categories=Utility;

chmod +x ~/Escritorio/MiCarpeta.desktop

nano ~/Escritorio/trash.desktop
[Desktop Entry]
Type=Application
Name=Papelera
Comment=Ver los archivos eliminados
Exec=dolphin trash:/
Icon=user-trash
Terminal=false
Categories=System;

chmod +x ~/Escritorio/Papelera.desktop
