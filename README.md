# Dotfiles & Snippets Hub

A curated collection of personal dotfiles, shell utilities, installation scripts, and helpful snippets for a productive Linux workflow. Designed for Arch Linux and Debian‑based systems, but many parts are portable.

## 📂 Repository Structure

```
dotfiles-snippets/
├── 01_disk_utilities/       # Globally executable disk/ISO utility scripts
│   ├── 00_iso-flasher.sh    # Write ISO images to USB/internal drives with verification
│   ├── 02_disk-formatter.sh # Disk formatting utility
│   └── 04_iso-hybrid-writer.sh  # Hybrid fast-flash script
│
├── 02_os_installers/        # OS-specific post-installation and update scripts
│   ├── arch/                # Arch Linux specific scripts and guides
│   │   ├── dms-installer.sh # Desktop-manager / display-server setup
│   │   ├── endeavouros-guide.md # EndeavourOS post-install guide
│   │   ├── manjaro-guide.md # Manjaro KDE post-install guide
│   │   ├── pkg-installer.sh # Full package install + AUR (yay)
│   │   ├── pkg-list.sh      # Package list reference
│   │   ├── update-automate.sh # Automated system update for Arch/Manjaro
│   │   └── wireguard-gen.sh # WireGuard VPN configuration generator
│   │
│   └── debian/              # Debian/Ubuntu specific scripts
│       ├── dms-installer.sh # Desktop-manager setup for Debian
│       ├── pkg-installer.sh # APT package installation for Debian/Ubuntu
│       ├── update-automate.sh # Automated system update for Debian/Ubuntu
│       └── wireguard-gen.sh # WireGuard setup for Debian
│
├── 03_network_vpn/          # Network and VPN configurations
│   ├── 26_wireguard-server.conf   # WireGuard server config
│   ├── 27_wireguard-deb-walkthrough.sh # WireGuard Debian tutorial
│   └── 29_wireguard-auto-setup.sh      # WireGuard auto-setup
│
├── 04_rescue_ssh/           # Rescue, SSH, and utility scripts
│   ├── 22_pgen.py                 # Cryptographically secure password generator (CLI & Service)
│   ├── 24_ubuntu-macos-theme.sh   # macOS theme setup for Ubuntu Cinnamon
│   ├── 31_system-rescue.sh        # System rescue & diagnosis
│   ├── 33_ssh-multi-account.sh    # SSH multi-account config generator
│   └── 35_lambda-utils.ts         # TypeScript utility class
│
└── 05_shell_configs/        # Shell configurations and functions
    ├── .zshrc               # Feature-rich Zsh setup
    ├── 36_zsh-config        # Configuration details for Zsh
    ├── 37_bash-config       # Bash counterpart configuration
    └── 38_zsh-functions     # Extra Zsh functions (git, qemu, hash, download)
```

## 🚀 Quick Start

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/dotfiles-snippets.git
   cd dotfiles-snippets
   ```

2. **Apply the shell configuration**

   - For **Zsh** (recommended):

     ```bash
     cp 05_shell_configs/.zshrc ~/.zshrc
     source ~/.zshrc
     ```

   - For **Bash**:

     ```bash
     cp 05_shell_configs/37_bash-config ~/.bashrc
     source ~/.bashrc
     ```

3. **Make the bin scripts available globally**

   ```bash
   sudo ln -s "$(pwd)/01_disk_utilities/*" /usr/local/bin/
   # or add $PWD/01_disk_utilities to your $PATH
   export PATH="$PATH:$(pwd)/01_disk_utilities"
   ```

4. **Run an OS‑specific installer (optional)**

   - Arch Linux / Manjaro / BigLinux:

     ```bash
     sudo ./02_os_installers/arch/pkg-installer.sh
     ```

   - Debian / Ubuntu / Linux Mint:

     ```bash
     sudo ./02_os_installers/debian/pkg-installer.sh
     ```

   Afterwards you can run the desktop‑manager or WireGuard scripts as needed.

## 🛠️ Key Features

### Shell Functions (defined in `05_shell_configs/.zshrc`)

| Function | Description |
|----------|-------------|
| `create <framework> [name]` | Scaffold a new frontend project using **Bun**. Supported frameworks: `vite|v`, `astro|a`, `react|r`, `vue`, `svelte|s`, `next|n`. Interactive prompts if name omitted. |
| `download <mode> <url> [dest]` | Unified **yt‑dlp** wrapper. Modes: `video|v` (best MP4), `music|m|audio|a` (MP3), `playlist|p` (video/music playlist). |
| `get-windows <10|11> [dest]` | Download Windows LTSC ISOes from the Massgrave mirror, with automatic DNS fallback and VPN hints. |
| `verify-hash <action> …` | Calculate or compare file hashes (md5, sha1, sha256, sha384, sha512, blake2). Sub‑commands: `calculate`, `compare`. |
| `vm <create|run|full> …` | QEMU wrapper: create a qcow2 disk, launch a VM with optional ISO, or do both in one step (`full`). |
| `upload-main "<msg>"` | Quick git add/commit/push to `main`. |
| `upload-dev "<msg>"` | Merge `dev` into `main`, push, then return to `dev`. |

### Aliases (selected)

- `ls` → `eza -1 -l --icons` (colorful, icon‑enabled directory listing)
- `la` → `eza -la --icons -h` (long list with hidden files)
- `grep` → `rg` (ripgrep)
- `find` → `fd` (fast, user‑friendly find)
- `cat` → `bat` (if installed) via `zinit` plugins
- `docker` shortcuts: `dps`, `dstop`, `drm`, etc. (see `aliases.zsh`)
- `git` shortcuts: `gcmsg`, `gp`, `gpo`, `gca`, etc.
- System: `update` (`sudo pacman -Syyu --noconfirm`), `clean`, `reboot`, `poweroff`, etc.

### Bin Scripts

- `flasher-iso.sh`: Safely write an ISO to a USB or internal device, verify with `cmp`, and optionally eject.
- `formatter.sh`: Interactive disk formatting helper (uses `mkfs.*` with labels).
- `hybrid-ff.sh`: Combines partitioning, formatting, and ISO flashing in one flow.

### Install Scripts

- **Arch**: Installs base‑development tools, editors (Neovim, VS Code, Cursor), browsers (Brave, Librewolf, Mullvad), multimedia (VLC, OBS, Audacity), office suites, utilities (Timeshift, Zoxide, Fastfetch, etc.), then optionally AUR packages via `yay`.
- **Debian**: Similar set using `apt`, covering essential productivity tools.

### Scripts Folder

- Contains ready‑to‑use WireGuard configurations (`wg0.conf`, `wg0-conf.sh`, `wireguard.sh`).
- Rescue helpers for filesystem checks, chroot, and system recovery.
- SSH config generator for Git hosting services.

## 📦 Requirements

- **Shell**: Zsh (recommended) or Bash.
- **Package Manager**:
  - Arch: `pacman` + optionally `yay` (for AUR).
  - Debian/Ubuntu: `apt`.
- **Optional but recommended**:
  - `bun` (for the `create` function).
  - `yt-dlp` (for `download`).
  - `qemu-full` (for `vm`).
  - `wireguard-tools` (for WireGuard scripts).
  - `zenity` or `xdg-open` (for GUI file picking in `flasher-iso.sh`).

## 🛠️ Installation & Usage Examples

### 1. Scaffold a Vite project with Bun

```bash
create vite my-web-app
# → prompts for name if omitted, then:
#   bun create vite@latest my-web-app
#   cd my-web-app && bun install
```

### 2. Download a YouTube video as MP3

```bash
download music https://youtu.be/dQw4w9WgXcQ ~/Music
```

### 3. Verify a file’s SHA‑256 hash

```bash
verify-hash calculate ~/Downloads/file.iso
# or compare:
verify-hash compare ~/Downloads/file.iso <expected-hash>
```

### 4. Create and run a Windows 10 VM with QEMU

```bash
# Create a 30 GB disk
vm create win10.qcow2 30G
# Start the VM with 4 GB RAM, 2 CPUs, and an ISO
vm run 4G 2 win10.qcow2 ./Win10_LTSC_2021_Enterprise_ES-ES.iso
# Or do both in one step:
vm full win10.qcow2 30G 4G 2 ./Win10_LTSC_2021_Enterprise_ES-ES.iso
```

### 5. Flash an ISO to a USB drive

```bash
sudo flasher-iso.sh --device /dev/sdb --file ~/ISOs/archlinux.iso
# The script will unmount, wipe, copy with progress bar, verify, and eject if removable.
```

## 🔧 Customisation

- **Shell theme**: The `.zshrc` uses **Powerlevel10k**. Run `p10k configure` to tweak the prompt.
- **Plugins**: Managed via **Zinit**. Edit the plugin block in `.zshrc` to add/remove.
- **Aliases & functions**: Drop your own files under `05_shell_configs/` and source them from `.zshrc`/`.bashrc`.
- **Bin scripts**: Modify the scripts in `01_disk_utilities/` to suit your workflow; they are deliberately kept simple and well‑commented.

## 📜 License

This project is licensed under the MIT License – see the [`LICENSE`](LICENSE) file for details.

## 🙏 Acknowledgements

- Inspiration from various dotfiles repositories on GitHub.
- The amazing open‑source tools: `zinit`, `powerlevel10k`, `eza`, `ripgrep`, `fd`, `bat`, `bun`, `yt-dlp`, `qemu`, `WireGuard`, and many more.

---

*Feel free to explore, fork, and adapt these dotfiles to your own needs. Happy hacking!*# 02_snippets-codes
