#!/usr/bin/env zsh

# ==============================================================================
# 📦 GLOBAL CONFIGURATION & VARIABLES
# ==============================================================================

# Path to the main directory where web development projects are created.
export MIS_PROYECTOS_DIR="$HOME/Proyectos"

# Global terminal ANSI escape colors used for styling diagnostics and script outputs.
export C_RED='\e[1;31m'
export C_GREEN='\e[1;32m'
export C_BLUE='\e[1;34m'
export C_CYAN='\e[1;36m'
export C_YELLOW='\e[1;33m'
export C_PURPLE='\e[1;35m'
export C_RESET='\e[0m'


# ==============================================================================
# 📦 DEVELOPMENT SCAFFOLDING
# ==============================================================================

# Scaffold a new modern web project (supporting Vite, Astro, Next.js, etc.) with a chosen package manager.
# Offers interactive menu options using 'gum' when no arguments are provided, otherwise falls back to standard prompts.
function create-web() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then 
        print -P "%F{cyan}Usage: create-web [framework] [project_name] [package_manager]%f\n"
        print "🛠️  Frameworks: vite(v), astro(a), next(n), react(r), vue, svelte(s)"
        print "📦 Managers:   bun, pnpm, npm, yarn"
        print "📂 Location:   Created in $MIS_PROYECTOS_DIR"
        return 0
    fi

    local fw="$1" proj="$2" pm="$3"

    # Show an interactive gum dialog if gum is installed and arguments are missing
    if command -v gum &>/dev/null; then
        [[ -z "$fw" ]] && fw=$(gum choose "vite" "astro" "next" "react" "vue" "svelte" --header "Select a framework:")
        [[ -z "$proj" ]] && proj=$(gum input --placeholder "e.g., my-awesome-app" --prompt "Project name: ")
        [[ -z "$pm" ]] && pm=$(gum choose "bun" "pnpm" "npm" "yarn" --header "Select a package manager:")
    fi

    # Validate framework input
    if [[ ! "$fw" =~ ^(vite|v|astro|a|next|n|nextjs|react|r|vue|svelte|s)$ ]]; then
        print -P "%F{red}❌ Invalid framework. Use 'create-web -h' for help.%f"
        return 1
    fi

    # Validate project name input
    if [[ -z "$proj" ]]; then
        print -n "🎯 Project name: "
        read -r proj
        [[ -z "$proj" ]] && { print -P "%F{red}❌ Scaffolding cancelled.%f"; return 1; }
    fi

    # Prevent overwriting an existing directory
    local target_dir="$MIS_PROYECTOS_DIR/$proj"
    if [[ -d "$target_dir" ]]; then
        print -P "%F{red}❌ Error: Directory '$target_dir' already exists.%f"
        return 1
    fi

    # Validate package manager input
    if [[ ! "$pm" =~ ^(npm|yarn|pnpm|bun)$ ]]; then
        print -n "📦 Package manager (npm/yarn/pnpm/bun) [default: bun]: "
        read -r pm
        pm=${pm:-bun}
    fi

    # Verify that the package manager is installed on the system
    if ! command -v "$pm" &>/dev/null; then
        print -P "%F{red}❌ Error: Package manager '$pm' is not installed on this system.%f"
        return 1
    fi

    # Access local project root
    mkdir -p "$MIS_PROYECTOS_DIR"
    cd "$MIS_PROYECTOS_DIR" || { print -P "%F{red}❌ Error: Could not access $MIS_PROYECTOS_DIR%f"; return 1; }

    # Setup command strings
    local create_cmd="$pm create" install_cmd="$pm install" dev_cmd="$pm run dev"
    [[ "$pm" == "yarn" ]] && install_cmd="yarn"

    local cmd=""
    case "$fw" in
        vite|v)          cmd="$create_cmd vite@latest \"$proj\"" ;;
        astro|a)         cmd="$create_cmd astro@latest \"$proj\"" ;;
        next|n|nextjs)   cmd="$create_cmd next-app@latest \"$proj\"" ;;
        react|r)         cmd="$create_cmd vite@latest \"$proj\" --template react" ;;
        vue)             cmd="$create_cmd vite@latest \"$proj\" --template vue" ;;
        svelte|s)        cmd="$create_cmd vite@latest \"$proj\" --template svelte" ;;
    esac

    # Run generator
    print -P "\n🚀 Generating project in %F{cyan}$target_dir%f using %F{yellow}$pm%f..."
    eval "$cmd" || return 1
    
    cd "$proj" || return 1
    print -P "\n⏳ Installing package dependencies..."
    eval "$install_cmd"
    
    print -P "\n%F{green}✅ Web project successfully generated!%f"
    print -P "To get started:\n  %F{cyan}cd $MIS_PROYECTOS_DIR/$proj%f\n  %F{yellow}$dev_cmd%f\n"
}


# ==============================================================================
# 📦 DOCKER INTERACTIVE UTILITIES
# ==============================================================================

# Interactively select a running Docker container and open a shell session inside it.
# Supports fzf and gum for container selection, and defaults to bash.
function dexec() {
    if [[ $# -gt 0 ]]; then
        docker exec -it "$@"
        return $?
    fi
    local container shell
    if command -v fzf &>/dev/null; then
        container=$(docker ps --format "{{.ID}} | {{.Names}} | {{.Image}}" | fzf | awk '{print $1}')
    elif command -v gum &>/dev/null; then
        container=$(docker ps --format "{{.Names}}" | gum choose)
    else
        print -P "%F{red}❌ Error: fzf or gum is required for interactive selection.%f"
        return 1
    fi
    [[ -z "$container" ]] && return 0
    
    if command -v gum &>/dev/null; then
        shell=$(gum choose "bash" "sh" "zsh" --header "Select shell:")
    else
        shell="bash"
    fi
    
    print -P "🚀 Entering container %F{cyan}$container%f via %F{yellow}$shell%f..."
    docker exec -it "$container" "$shell" || docker exec -it "$container" sh
}

# Interactively select a Docker container (running or stopped) and track/follow its logs.
# Requires fzf or gum for container selection.
function dlog() {
    if [[ $# -gt 0 ]]; then
        docker logs "$@"
        return $?
    fi
    local container
    if command -v fzf &>/dev/null; then
        container=$(docker ps -a --format "{{.ID}} | {{.Names}} | {{.Image}} ({{.Status}})" | fzf | awk '{print $1}')
    elif command -v gum &>/dev/null; then
        container=$(docker ps -a --format "{{.Names}}" | gum choose)
    else
        print -P "%F{red}❌ Error: fzf or gum is required for interactive selection.%f"
        return 1
    fi
    [[ -z "$container" ]] && return 0
    
    print -P "📺 Tailing logs for container %F{cyan}$container%f (Ctrl+C to exit)..."
    docker logs -f "$container"
}

# Safe interactive wizard to prune stopped containers, dangling images, unused volumes, and networks.
function dclean() {
    print -P "%F{yellow}🧹 Docker Cleanup Wizard%f"
    if command -v gum &>/dev/null; then
        gum confirm "Are you sure you want to prune all unused Docker data?" && docker system prune -a --volumes --force
    else
        print -n "Are you sure you want to prune all unused Docker data? (y/N): "
        read -r response
        if [[ "$response" =~ ^[yY]$ ]]; then
            docker system prune -a --volumes --force
        else
            print "Prune cancelled."
        fi
    fi
}

# Display IP addresses and port mappings of all running Docker containers in a compact table.
function dip() {
    local format_str='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}" | while read -r line; do
        if [[ "$line" =~ ^CONTAINER ]]; then
            printf "%-15s %-25s %-15s %-30s\n" "CONTAINER ID" "NAMES" "IP ADDRESS" "PORTS"
            continue
        fi
        local id=$(echo "$line" | awk '{print $1}')
        local name=$(echo "$line" | awk '{print $2}')
        local ports=$(echo "$line" | cut -d' ' -f3-)
        local ip=$(docker inspect -f "$format_str" "$id")
        printf "%-15s %-25s %-15s %-30s\n" "$id" "$name" "${ip:-N/A}" "${ports:-None}"
    done
}


# ==============================================================================
# 📦 DEVELOPMENT UTILITIES
# ==============================================================================

# Identify and terminate the process holding/listening on a specified local network port.
# Prompts for verification before killing the process.
function killport() {
    local port="$1"
    if [[ -z "$port" ]]; then
        print -P "%F{red}❌ Error: Port number is required (e.g., killport 8080).%f"
        return 1
    fi
    local pid=$(lsof -t -i:"$port" 2>/dev/null)
    if [[ -z "$pid" ]]; then
        print -P "%F{yellow}⚠️ No process found listening on port $port.%f"
        return 0
    fi
    print -P "%F{cyan}Process %F{yellow}$pid%f ($(ps -p "$pid" -o comm=)) is listening on port $port.%f"
    if command -v gum &>/dev/null; then
        gum confirm "Kill this process?" && kill -9 "$pid"
    else
        print -n "Kill this process? (y/N): "
        read -r response
        if [[ "$response" =~ ^[yY]$ ]]; then
            kill -9 "$pid"
            print -P "%F{green}Process terminated.%f"
        fi
    fi
}

# Automatically extract common archive formats based on their file extension.
# Supports tar, gz, bz2, zip, rar, 7z, and more.
function extract() {
    if [[ -z "$1" ]]; then
        print -P "%F{red}❌ Error: File name required (e.g., extract archive.tar.gz).%f"
        return 1
    fi
    if [[ ! -f "$1" ]]; then
        print -P "%F{red}❌ Error: File '$1' does not exist.%f"
        return 1
    fi
    case "$1" in
        *.tar.bz2|*.tbz2) tar xvjf "$1" ;;
        *.tar.gz|*.tgz)  tar xvzf "$1" ;;
        *.tar.xz)        tar xvJf "$1" ;;
        *.tar)           tar xvf "$1"  ;;
        *.bz2)           bunzip2 "$1"  ;;
        *.rar)           unrar x "$1"  ;;
        *.gz)            gunzip "$1"   ;;
        *.zip)           unzip "$1"    ;;
        *.Z)             uncompress "$1" ;;
        *.7z)            7z x "$1"     ;;
        *)               print -P "%F{red}❌ Error: '$1' cannot be extracted via extract.%f"; return 1 ;;
    esac
}

# Delete all local branches that have already been merged into the default remote branch.
# Synchronizes with origin before checking for merged branches.
function git-prune-branches() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        print -P "%F{red}❌ Error: Not a Git repository.%f"
        return 1
    fi
    local default_branch=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
    default_branch="${default_branch:-main}"
    print -P "Checking merged branches against %F{cyan}$default_branch%f..."
    git checkout "$default_branch" && git pull origin "$default_branch" && git fetch -p || return 1
    
    local branches=$(git branch --merged | grep -v "^\*" | grep -v "$default_branch")
    if [[ -z "$branches" ]]; then
        print -P "%F{green}✨ No merged local branches to prune.%f"
        return 0
    fi
    print "The following local branches are merged and will be deleted:"
    print "$branches"
    if command -v gum &>/dev/null; then
        gum confirm "Delete these branches?" && echo "$branches" | xargs git branch -d
    else
        print -n "Delete these branches? (y/N): "
        read -r response
        if [[ "$response" =~ ^[yY]$ ]]; then
            echo "$branches" | xargs git branch -d
        fi
    fi
}


# ==============================================================================
# 📦 MEDIA DOWNLOADERS
# ==============================================================================

# Download media (video, audio/music, or playlist) from YouTube/supported sites using yt-dlp.
# Automatically sets up optimized encoders, embeds metadata, and creates directories.
function download() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then 
        print -P "%F{cyan}Usage: download <video|music|playlist> <url> [destination_dir]%f\n"
        print "Modes: video (v), music (m), playlist (p)"
        return 0 
    fi
    
    if ! command -v yt-dlp &>/dev/null; then
        print -P "%F{red}❌ Error: yt-dlp is not installed. Please install it first.%f"
        return 1
    fi
    
    local mode="$1" url="$2" dir="$3"
    if [[ -z "$url" ]]; then
        print -P "%F{red}❌ Error: Missing URL.%f"
        return 1
    fi

    local args=()
    case "$mode" in
        video|v) 
            dir="${dir:-$HOME/Vídeos/youtube-videos}"
            args=(-f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]" --merge-output-format mp4 --embed-thumbnail --add-metadata -o "$dir/%(title)s.%(ext)s") 
            ;;
        music|m|audio|a) 
            dir="${dir:-$HOME/Música}"
            args=(-x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata -o "$dir/%(title)s.%(ext)s") 
            ;;
        playlist|p) 
            dir="${dir:-$HOME/Vídeos/youtube-playlists}"
            args=(--yes-playlist -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]" --merge-output-format mp4 --embed-thumbnail --add-metadata -o "$dir/%(playlist_title)s/%(title)s.%(ext)s")
            ;;
        *)
            print -P "%F{red}❌ Error: Invalid mode. Use 'video', 'music', or 'playlist'.%f"
            return 1 
            ;;
    esac

    mkdir -p "$dir"
    print -P "⬇️  Downloading media into: %F{blue}$dir%f"
    
    local final_cmd=(yt-dlp "${args[@]}")
    local cookies="$HOME/.config/yt-dlp/cookies.txt"
    [[ -f "$cookies" ]] && final_cmd+=(--cookies "$cookies")
    
    "${final_cmd[@]}" "$url" && print -P "%F{green}✅ Download completed!%f" || print -P "%F{red}⚠️ Download failed.%f"
}


# ==============================================================================
# 📦 FILE INTEGRITY VERIFICATION
# ==============================================================================

# Calculate or verify file integrity checksums (supporting sha256, md5, sha1, etc.).
# Performs case-insensitive matching when comparing against expected hash results.
function verifyhash() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then 
        print -P "%F{cyan}Usage: verifyhash calc <file> [algorithm]%f"
        print -P "%F{cyan}       verifyhash comp <file> <expected_hash> [algorithm]%f"
        return 0 
    fi

    local action="$1" file="$2" expected="$3" algo="${4:-sha256}"

    _calc() {
        local target_file="$1" hash_algo="$2"
        local cmd="${hash_algo:l}sum"
        if ! command -v "$cmd" &>/dev/null; then
            cmd="sha256sum"
        fi
        $cmd "$target_file" 2>/dev/null | awk '{print $1}'
    }

    if [[ ! -f "$file" ]]; then
        print -P "%F{red}❌ Error: File '$file' does not exist.%f"
        return 1
    fi

    if [[ "$action" =~ ^(calculate|calc|c)$ ]]; then
        algo="${expected:-sha256}"
        local result=$(_calc "$file" "$algo")
        print -P "%F{blue}📊 Calculated Hash ($algo):%f\n$result"
        
    elif [[ "$action" =~ ^(compare|comp)$ ]]; then
        if [[ -z "$expected" ]]; then
            print -P "%F{red}❌ Error: Expected hash is required for comparison.%f"
            return 1
        fi
        local result=$(_calc "$file" "$algo")
        
        if [[ "${result:l}" == "${expected:l}" ]]; then
            print -P "%F{green}✅ VERIFICATION SUCCESSFUL! The checksums match.%f"
        else
            print -P "%F{red}❌ CHECKSUM MISMATCH!%f"
            print -P "Expected:   %F{yellow}$expected%f"
            print -P "Calculated: %F{red}$result%f"
            return 1
        fi
    else
        print -P "%F{red}❌ Error: Invalid action. Use 'calc' or 'comp'.%f"
        return 1
    fi
}


# ==============================================================================
# 📦 GIT HELPERS & AUTOMATION
# ==============================================================================

# Internal helper to auto-detect the current Git branch namespace type.
# Maps features, hotfixes, and documentation branches to semantic commit prefixes.
function _git_branch_type() {
    local b=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    case "$b" in 
        feature/*|minor/*) echo "feat" ;; 
        patch/*|hotfix/*) echo "fix" ;; 
        docs/*) echo "docs" ;; 
        *) echo "" ;; 
    esac
}

# Automate repository workflows: stages files, commits with context headers, merges branches, and pushes to remote origin.
# Fully interactive with gum inputs if installed for commit messaging.
function git-magic() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then 
        print -P "%F{cyan}Usage: git-magic [-a] [-p] [-d <branch>] \"message\"%f"
        print "  -a          : Run 'git add .'"
        print "  -p          : Run 'git push'"
        print "  -d <branch> : Merge current branch into <branch>, push, and switch back."
        print "Example: git-magic -a -p \"feat: add authentication screen\""
        return 0
    fi

    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        print -P "%F{red}❌ Error: Current directory is not a Git repository.%f"
        return 1
    fi

    local do_add=0 do_push=0 do_deploy="" msg=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a) do_add=1; shift ;;
            -p) do_push=1; shift ;;
            -d) do_deploy="$2"; shift 2 ;;
            *) msg="$1"; shift ;;
        esac
    done

    # 1. Staging area
    if [[ $do_add -eq 1 ]]; then
        print "➕ Staging files (git add .)..."
        git add . || return 1
    fi

    # 2. Committing
    if [[ -n "$msg" ]]; then
        local prefix=$(_git_branch_type)
        local full_msg="${prefix:+$prefix: }$msg"
        
        if command -v gum &>/dev/null; then
            full_msg=$(gum input --placeholder "Commit message" --value "$full_msg")
            [[ -z "$full_msg" ]] && { print "❌ Commit aborted."; return 1; }
        fi
        print "📝 Committing changes..."
        git commit -m "$full_msg" || return 1
    fi

    # 3. Deploy (Merge to target branch)
    if [[ -n "$do_deploy" ]]; then
        local current_branch=$(git branch --show-current)
        if [[ "$current_branch" == "$do_deploy" ]]; then
            print -P "%F{yellow}⚠️ Already on '$do_deploy'. Skipping merge.%f"
        else
            print -P "🚀 Deploying and merging into '%F{cyan}$do_deploy%f'..."
            git checkout "$do_deploy" && \
            git pull origin "$do_deploy" && \
            git merge "$current_branch" && \
            git push origin "$do_deploy" && \
            git checkout "$current_branch" || return 1
        fi
    fi

    # 4. Push to current remote branch
    if [[ $do_push -eq 1 ]]; then
        local cur_branch=$(git branch --show-current)
        print "☁️ Pushing to origin/$cur_branch..."
        git push origin "$cur_branch" || return 1
    fi
    print -P "%F{green}✅ Git magic successfully completed!%f"
}


# ==============================================================================
# 📦 VIRTUAL MACHINE MANAGEMENT
# ==============================================================================

# Manage QEMU virtual machines (creates virtual disk files, handles ISO mounting, and controls execution parameters).
# Automatically checks for hardware virtualization (KVM) access and applies system optimization arguments.
function vm() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then 
        print -P "%F{cyan}Usage: vm <create|run|full> [options]%f"
        print "  create <disk.qcow2> <size>              : Create a QCOW2 disk image (e.g. size: 20G)"
        print "  run <ram> <cpus> <disk> [iso] [vendor:prod] : Run VM (ram: 4G, cpus: 2, optional iso/usb)"
        print "  full <disk> <size> <ram> <cpus> [iso]   : Create and launch a VM in one step"
        return 0
    fi
    
    if ! command -v qemu-system-x86_64 &>/dev/null; then
        print -P "%F{red}❌ Error: QEMU is not installed (qemu-system-x86_64 not found).%f"
        return 1
    fi
    
    local action="$1"; shift
    case "$action" in
        create) 
            local file="$1" size="$2"
            if [[ -z "$file" || -z "$size" ]]; then
                print "Usage: vm create <disk.qcow2> <size (e.g. 20G)>"
                return 1
            fi
            if ! command -v qemu-img &>/dev/null; then
                print -P "%F{red}❌ Error: qemu-img utility not found.%f"
                return 1
            fi
            qemu-img create -f qcow2 "$file" "$size" 
            ;;
        run)
            local ram="$1" cpus="$2" disco="$3" iso="$4" usb="$5"
            if [[ -z "$ram" || -z "$cpus" || -z "$disco" ]]; then
                print "Usage: vm run <RAM> <CPUs> <disk.qcow2> [iso_file] [usb_vendor:product]"
                return 1
            fi
            if [[ ! -f "$disco" ]]; then
                print -P "%F{red}❌ Error: Disk image '$disco' not found.%f"
                return 1
            fi
            
            # Detect KVM device permissions
            local kvm=(-cpu qemu64)
            [[ -w /dev/kvm ]] && kvm=(-enable-kvm -cpu host)
            
            local usb_args=(-device qemu-xhci)
            if [[ -n "$usb" ]]; then 
                local v="${usb%:*}" p="${usb#*:}"
                usb_args=(-device qemu-xhci,id=usb -device usb-host,vendorid=0x$v,productid=0x$p)
            fi
            
            local args=(qemu-system-x86_64 -M q35 "${kvm[@]}" -m "$ram" -smp "$cpus" \
                -drive file="$disco",format=qcow2 -netdev user,id=net -device e1000,netdev=net \
                -vga std "${usb_args[@]}" -device usb-tablet)
            
            if [[ -n "$iso" && -f "$iso" ]]; then 
                args+=(-cdrom "$iso" -boot d)
            else 
                args+=(-boot c)
            fi
            
            if [[ -n "$usb" ]]; then 
                sudo "${args[@]}"
            else 
                "${args[@]}"
            fi 
            ;;
        full) 
            local file="$1" size="$2" ram="$3" cpus="$4" iso="$5"
            if [[ -z "$file" || -z "$size" || -z "$ram" || -z "$cpus" ]]; then
                print "Usage: vm full <disk.qcow2> <size> <RAM> <CPUs> [iso]"
                return 1
            fi
            vm create "$file" "$size" && vm run "$ram" "$cpus" "$file" "$iso" 
            ;;
        *) 
            print -P "%F{red}❌ Error: Invalid action. Supported actions: create, run, full%f"
            return 1
            ;;
    esac
}


# ==============================================================================
# 📦 SYSTEM PACKAGE MANAGERS
# ==============================================================================

# Unified system package manager wrapper for Arch Linux using yay.
# Simplifies installation, removal, update, cleanup, and keys re-initialization.
function pkg() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then 
        print -P "%F{cyan}Usage: pkg <i|r|u|c|k|conf> [package_name]%f"
        print "  i, install : Install packages"
        print "  r, remove  : Remove packages and configurations"
        print "  u, update  : Sync repositories, update system packages and flatpaks"
        print "  c, clean   : Clean build caches and orphan packages"
        print "  k, keys    : Reinitialize pacman keyring and sign keys"
        print "  conf       : Edit pacman.conf configuration file"
        return 0
    fi
    
    if ! command -v yay &>/dev/null; then
        print -P "%F{red}❌ Error: yay package manager is not installed.%f"
        return 1
    fi
    
    case "$1" in
        i|install) 
            shift
            [[ -z "$1" ]] && { print -P "%F{red}❌ Error: Package name not specified.%f"; return 1; }
            yay -S --noconfirm "$@" 
            ;;
        r|remove) 
            shift
            [[ -z "$1" ]] && { print -P "%F{red}❌ Error: Package name not specified.%f"; return 1; }
            yay -Rns --noconfirm "$@" 
            ;;
        u|update) 
            print "🚀 Checking system updates..."
            yay -Syu --noconfirm
            command -v flatpak &>/dev/null && flatpak update -y
            pkg clean 
            ;;
        c|clean) 
            print "🧹 Performing package cleanup..."
            yay -Sc --noconfirm
            yay -Yc --noconfirm || print "✨ No orphans found." 
            ;;
        k|keys) 
            print "🔑 Updating keyring keys..."
            sudo pacman-key --init
            sudo pacman-key --populate archlinux
            sudo pacman -Sy archlinux-keyring --noconfirm 
            ;;
        conf) 
            sudo "${EDITOR:-nano}" /etc/pacman.conf 
            ;;
        *) 
            print -P "%F{red}❌ Error: Command not recognized. Options: i, r, u, c, k, conf%f"
            return 1
            ;;
    esac
}

# Unified package manager wrapper for Debian/Ubuntu systems using nala (fallback to apt).
# Simplifies installation, removal, update, cleanup, and repository searching.
function pkg-deb() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then 
        print -P "%F{cyan}Usage: pkg-deb <i|r|u|c|s> [package_name]%f"
        print "  i, install : Install packages"
        print "  r, remove  : Purge packages and remove dependencies"
        print "  u, update  : Sync package list and upgrade system packages"
        print "  c, clean   : Autoremove unused packages and clear apt cache"
        print "  s, search  : Search repositories for matching packages"
        return 0
    fi

    local pm
    if command -v nala &> /dev/null; then 
        pm="nala" 
    else 
        pm="apt"
    fi
    
    case "$1" in
        i|install) 
            shift
            [[ -z "$1" ]] && { print -P "%F{red}❌ Error: Package name required.%f"; return 1; }
            sudo $pm install -y "$@" 
            ;;
        r|remove) 
            shift
            [[ -z "$1" ]] && { print -P "%F{red}❌ Error: Package name required.%f"; return 1; }
            sudo $pm autoremove --purge -y "$@" 
            ;;
        u|update) 
            print "🚀 Upgrading system packages..."
            sudo $pm update && sudo $pm upgrade -y
            pkg-deb clean 
            ;;
        c|clean) 
            print "🧹 Cleaning package manager cache..."
            sudo $pm autoremove -y && sudo $pm autoclean
            if [[ "$pm" == "nala" ]]; then 
                sudo nala clean
            else 
                sudo apt clean
            fi 
            ;;
        s|search) 
            shift
            [[ -z "$1" ]] && { print -P "%F{red}❌ Error: Search query required.%f"; return 1; }
            $pm search "$@" 
            ;;
        *) 
            print -P "%F{red}❌ Error: Option not recognized. Options: i, r, u, c, s%f"
            return 1
            ;;
    esac
}


# ==============================================================================
# 📦 SYSTEM DIAGNOSTICS & INFO
# ==============================================================================

# Retrieve and format system information metrics, user sessions, network interfaces, disk space, and hardware specs.
# Can display individual metrics or all details concurrently.
function sysinfo() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then 
        print -P "%F{cyan}Usage: sysinfo [options]%f"
        print "  -u  : User attributes and login details"
        print "  -k  : OS release version, hostname, and kernel release"
        print "  -n  : Current network interfaces and IP addresses"
        print "  -d  : Disk layout size and mountpoints"
        print "  -hw : CPU model, total RAM, and GPU specs"
        print "  -s  : Software metrics and package manager details"
        print "  -x  : Memory diagnostics and failed systemd services"
        print "  -f  : System specification summary (via fastfetch)"
        print "  -a  : Run and output all metrics concurrently"
        return 0
    fi

    local CB="\e[1;35m" CT="\e[1;36m" CK="\e[1;33m" CV="\e[0m"
    _p_h() { 
        print "\n${CT}=== $1 ===${CV}"
        printf "${CB}┌─%-35s─┬─%-65s─┐${CV}\n" "───" "───"
        printf "${CB}│${CT} %-35s ${CB}│${CT} %-65s ${CB}│${CV}\n" "$2" "$3"
        printf "${CB}├─%-35s─┼─%-65s─┤${CV}\n" "───" "───"
    }
    _p_r() { 
        printf "${CB}│${CK} %-35.35s ${CB}│${CV} %-65.65s ${CB}│${CV}\n" "$1" "$2" 
    }
    _p_f() { 
        printf "${CB}└─%-35s─┴─%-65s─┘${CV}\n" "───" "───" 
    }

    case "$1" in
        -u) 
            _p_h "USUARIO" "ATRIBUTO" "VALOR"
            _p_r "Usuario" "$(whoami)"
            _p_r "Grupos" "$(id -Gn | tr ' ' ', ')"
            _p_f 
            ;;
        -k) 
            _p_h "SISTEMA" "COMPONENTE" "DETALLE"
            _p_r "Hostname" "$(hostname)"
            _p_r "Distribución" "$(grep '^PRETTY_NAME=' /etc/os-release | cut -d '"' -f2 2>/dev/null || echo 'Unknown')"
            _p_r "Kernel" "$(uname -r)"
            _p_f 
            ;;
        -n) 
            _p_h "RED" "INTERFAZ" "ESTADO / IP"
            if command -v ip &>/dev/null; then
                ip -br addr show | grep -vE "^(lo|tailscale|docker|veth|br-)" | while read -r i s ip; do 
                    _p_r "$i" "$s | $ip"
                done
            else
                _p_r "ip command" "Not installed"
            fi
            _p_f 
            ;;
        -d) 
            _p_h "DISCOS" "PARTICIÓN" "TAMAÑO | FORMATO | MONTAJE"
            if command -v lsblk &>/dev/null; then
                lsblk -p -o NAME,SIZE,FSTYPE,MOUNTPOINT -n -r | grep -v "loop" | while read -r n s f m; do 
                    _p_r "$n" "$s | ${f:--} | ${m:--}"
                done
            else
                _p_r "lsblk command" "Not installed"
            fi
            _p_f 
            ;;
        -hw) 
            _p_h "HARDWARE" "COMPONENTE" "ESPECIFICACIÓN"
            _p_r "CPU" "$(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs 2>/dev/null || echo 'Unknown')"
            _p_r "RAM" "$(free -h | awk '/^Mem:/ {print $2}' 2>/dev/null || echo 'Unknown')"
            _p_r "GPU" "$(lspci 2>/dev/null | grep -i 'vga\|3d\|display' | head -1 | cut -d: -f3 | xargs || echo 'Not detected')"
            _p_f 
            ;;
        -s) 
            _p_h "SOFTWARE" "GESTOR" "ESTADO"
            _p_r "Pacman" "$(pacman -Qq 2>/dev/null | wc -l 2>/dev/null || echo '0') packages"
            command -v flatpak &>/dev/null && _p_r "Flatpak" "$(flatpak list --app 2>/dev/null | wc -l) apps"
            _p_f 
            ;;
        -x) 
            _p_h "SALUD" "MÉTRICA" "VALOR"
            _p_r "RAM Usada" "$(free -h | awk '/^Mem:/ {print $3 " / " $2}' 2>/dev/null || echo 'Unknown')"
            _p_r "Servicios Fallidos" "$(systemctl --failed --no-legend | wc -w 2>/dev/null || echo '0')"
            _p_f 
            ;;
        -f) 
            _p_h "RESUMEN" "MÉTRICA" "VALOR"
            if command -v fastfetch &>/dev/null; then
                fastfetch --logo none -s OS:Host:Kernel:Uptime:Packages:Shell:CPU:GPU:Memory:Disk 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | while IFS=':' read -r k v; do 
                    [[ -n "$k" ]] && _p_r "$(echo $k | xargs)" "$(echo $v | xargs)"
                done
            else
                _p_r "fastfetch command" "Not installed"
            fi
            _p_f 
            ;;
        -a) 
            sysinfo -u
            sysinfo -k
            sysinfo -f
            sysinfo -n
            sysinfo -d
            sysinfo -hw
            sysinfo -s
            sysinfo -x 
            ;;
        *) 
            print -P "%F{red}❌ Error: Invalid option. Use 'sysinfo -h' for details.%f"
            return 1
            ;;
    esac
}


# ==============================================================================
# 📦 DOJO SHELL FUNCTIONS DIRECTORY
# ==============================================================================

# Print a beautiful directory listing details and usage tips for all available custom Dojo helper shell functions.
function zfuncs() {
    if command -v gum &>/dev/null; then
        gum style --border double --border-foreground 57 --foreground 212 \
            --padding "1 2" --margin "1" "🥷 FUNCIONES PERSONALIZADAS DEL DOJO"
    else
        print -P "\n%F{purple}🥷 FUNCIONES PERSONALIZADAS DEL DOJO%f\n"
    fi
    print -P "  %F{cyan}🐙 git-magic%f         : Stage, commit, push y deploy en 1 paso. Aliases: %F{yellow}gacp, gac, gpd%f"
    print -P "  %F{cyan}🧹 git-prune-branches%f: Elimina ramas locales ya fusionadas con la rama por defecto."
    print -P "  %F{cyan}🛠️  create-web%f        : Creación de proyectos web (Vite, Next, Astro). Uso: %F{yellow}create-web vite app%f"
    print -P "  %F{cyan}🐳 dexec%f             : Entra de forma interactiva a un contenedor Docker."
    print -P "  %F{cyan}🐳 dlog%f              : Muestra y sigue de forma interactiva los logs de un contenedor."
    print -P "  %F{cyan}🐳 dclean%f            : Limpia contenedores, imágenes y volúmenes de Docker no usados."
    print -P "  %F{cyan}🐳 dip%f               : Muestra IPs y puertos de los contenedores Docker activos."
    print -P "  %F{cyan}🔌 killport%f          : Termina el proceso que esté escuchando en un puerto específico."
    print -P "  %F{cyan}📦 pkg / pkg-deb%f     : Envoltorios unificados para gestores de paquetes Arch y Debian/Ubuntu."
    print -P "  %F{cyan}🗜️  extract%f          : Extrae automáticamente múltiples tipos de archivos comprimidos."
    print -P "  %F{cyan}⬇️  download%f          : Descarga videos/audio de Youtube con yt-dlp."
    print -P "  %F{cyan}🔐 verifyhash%f        : Calcula o compara la integridad (checksum) de un archivo."
    print -P "  %F{cyan}💻 vm%f                : Administra máquinas virtuales QEMU de forma simplificada."
    print -P "  %F{cyan}📊 sysinfo%f           : Diagnóstico completo y resumen del sistema. Uso: %F{yellow}sysinfo -a%f"
    print -P "  %F{cyan}🔑 passgen%f           : Genera contraseñas aleatorias seguras de diversos tipos."
    print -P "\n  %F{yellow}💡 Consejo: Escribe \`<comando> -h\` o \`<comando> --help\` para ver opciones y ayuda.%f\n"
}


function passgen() {
    local -a FW=("agua" "arbol" "arena" "barco" "brisa" "cielo" "cueva" "disco" "duna" "fuego" "gato" "globo" "hoja" "humo" "isla" "lago" "lluvia" "luna" "mapa" "monte" "nieve" "nube" "onda" "papel" "piedra" "pino" "pluma" "rayo" "rio" "roca" "selva" "sol" "suelo" "tierra" "torre" "viento" "vuelo" "valle" "verde" "vida" "azul" "rojo" "claro" "oscuro" "fuerte" "suave" "rapido" "lento" "alto" "bajo" "acid" "apex" "atom" "bark" "beam" "bolt" "brisk" "calm" "clay" "coal" "dawn" "deep" "dusk" "echo" "fade" "flow" "flux" "glen" "glow" "halo" "haze" "iron" "jade" "lava" "leaf" "lime" "mist" "neon" "nova" "opal" "path" "pure" "rain" "reef" "rift" "rust" "sand" "shadow" "silk" "silt" "snow" "star" "surf" "tide" "vale" "vast" "wave" "wild" "wind" "zinc")
    local t="secure" l="" c="" q=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -S) t="secure";; -M) t="matricula";; -A) t="alphanumeric";;
            -N) t="numeric";; -X) t="memorable";;
            -h) echo "Uso: pgen [longitud] [cantidad] [qty] [-S|-M|-A|-N|-X|-h]"; return 0;;
            -*) echo "Flag inválido: $1" >&2; return 1;;
            *) [[ -z "$l" ]] && l="$1" || { [[ -z "$c" ]] && c="$1" || q="$1"; };;
        esac; shift
    done

    [[ -z "$l" ]] && l=$(( t == "numeric" ? 6 : 16 ))
    [[ -z "$c" ]] && c=1
    [[ -z "$q" ]] && q=$(( t == "memorable" ? 4 : 1 ))

    local i j
    for (( i=0; i<c; i++ )); do
        case "$t" in
            matricula)
                local res="" cons="BCDFGHJKLMNPQRSTVWXYZ" digs="0123456789"
                for (( j=0; j<4; j++ )); do res+="${digs[$(( $(od -An -N4 -tu4 /dev/urandom | tr -d ' ') % 10 + 1 ))]}"; done
                for (( j=0; j<3; j++ )); do res+="${cons[$(( $(od -An -N4 -tu4 /dev/urandom | tr -d ' ') % 21 + 1 ))]}"; done
                echo "$res" ;;
            secure|alphanumeric|numeric)
                local low="abcdefghijklmnopqrstuvwxyz" up="ABCDEFGHIJKLMNOPQRSTUVWXYZ" num="0123456789"
                local sym='!@#$%^&*()_+-=[]{}|;:,.<>?' pool=""
                [[ "$t" == "numeric" ]] && pool="$num" || pool="${low}${up}${num}"
                [[ "$t" == "secure" ]] && pool+="$sym"
                local plen=${#pool} pwd="" hl=0 hu=0 hn=0 hs=0
                while true; do
                    pwd="" hl=0 hu=0 hn=0 hs=0
                    for (( j=0; j<l; j++ )); do
                        local ch="${pool[$(( $(od -An -N4 -tu4 /dev/urandom | tr -d ' ') % plen + 1 ))]}"
                        pwd+="$ch"
                        [[ "$ch" == [a-z] ]] && hl=1; [[ "$ch" == [A-Z] ]] && hu=1
                        [[ "$ch" == [0-9] ]] && hn=1; [[ "$ch" == [^a-zA-Z0-9] ]] && hs=1
                    done
                    if [[ "$t" == "numeric" ]] || \
                       { [[ "$t" == "alphanumeric" ]] && (( hl && hu && hn )); } || \
                       { [[ "$t" == "secure" ]] && (( hl && hu && hn && hs )); }; then
                        echo "$pwd"; break
                    fi
                done ;;
            memorable)
                local -a words=() p
                for p in /usr/share/dict/words /etc/dictionaries-common/words /usr/dict/words; do
                    [[ -f "$p" ]] && words=( ${(f)"$(awk '/^[a-z]{4,8}\r?$/ {sub(/\r/, ""); print}' "$p" 2>/dev/null)"} ) && (( ${#words[@]} > 0 )) && break
                done
                (( ${#words[@]} == 0 )) && words=( "${FW[@]}" )
                local wlen=${#words[@]} -a sel=()
                typeset -A picked
                while (( ${#sel[@]} < q )); do
                    local w="${words[$(( $(od -An -N4 -tu4 /dev/urandom | tr -d ' ') % wlen + 1 ))]}"
                    [[ -z "${picked[$w]}" ]] && { picked[$w]=1; sel+=("$w"); }
                done
                echo ${(j:-:)sel} ;;
        esac
    done
}