# After fresh installation, make this steps:


sudo nano /etc/pacman.conf
sudo nano /etc/sudoers
sudo nano /etc/default/Grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo pacman -S qt6-wayland Linux-headers base-devel open-vm-tools xf86-video-vmware gtkmm3
Chaotic AUR
sudo pacman -Sy flatpak
flatpak remote-add --if-not-exists --user flathub ttps://dl.flathub.org/repo/flathub.flatpakrepo
yay -Sy snapd
sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap
sudo systemctl enable --now snapd.apparmor  
yay -Sy libpamac-full pamac-all
sudo pacman -S neofetch fastfetch htop btop
Compresores
sudo pacman -S xz bzip2 p7zip lbzip2 lrzip arj lzop cpio unrar
Códecs
sudo pacman -S jasper lame libdca libdv gst-libav libtheora libvorbis libxv wavpack x264 xvidcore dvd+rw-tools dvdauthor dvgrab libmad libmpeg2 libdvdcss libdvdread libdvdnav exfat-utils fuse-exfat a52dec faac faad2 flac

Plymouth
sudo pacman -S mkinitcpio
sudo nano /etc/mkinitcpio.conf
HOOKS=(base udev plymouth autodetect modconf block filesystems keyboard fsck)
sudo yay -S plymouth plymouth-theme-endeavouros
sudo plymouth-set-default-theme -R endeavouros
sudo nano /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg