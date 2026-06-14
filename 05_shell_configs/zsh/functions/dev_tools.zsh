# ==============================================
# 🛠️ HERRAMIENTAS DE DESARROLLO
# ==============================================
function create-web() {
    [[ "$1" == "-h" ]] && { echo "Uso: create-web <vite|astro|next|react|vue|svelte> [nombre]"; return 0; }
    local fw="$1" proj="$2"
    if [[ ! "$fw" =~ ^(vite|v|astro|a|next|n|nextjs|react|r|vue|svelte|s)$ ]]; then
        echo "🛠️ Frameworks: vite(v), astro(a), next(n), react(r), vue, svelte(s)"
        return 1
    fi
    [[ -z "$proj" ]] && { echo -n "🎯 Nombre del proyecto: "; read proj; [[ -z "$proj" ]] && return 1; }
    
    local cmd=""
    case "$fw" in
        vite|v) cmd="bun create vite@latest \"$proj\"" ;;
        astro|a) cmd="bun create astro@latest \"$proj\"" ;;
        next|n|nextjs) cmd="bun create next-app@latest \"$proj\"" ;;
        react|r) cmd="bun create vite@latest \"$proj\" --template react" ;;
        vue) cmd="bun create vite@latest \"$proj\" --template vue" ;;
        svelte|s) cmd="bun create vite@latest \"$proj\" --template svelte" ;;
    esac

    echo "🚀 Generando andamiaje..."
    eval "$cmd" || return 1
    cd "$proj" || return 1
    bun install
    echo -e "\n✅ ¡Listo en $(pwd)! Usa: \e[1;33mbun run dev\e[0m"
}

function download() {
    [[ "$1" == "-h" ]] && { echo "Uso: download <video|music|playlist> <url> [carpeta]"; return 0; }
    command -v yt-dlp &>/dev/null || { echo "❌ Instala yt-dlp"; return 1; }
    
    local mode="$1" url="$2" dir="$3"
    [[ -z "$url" ]] && { echo "❌ Falta la URL"; return 1; }

    case "$mode" in
        video|v) dir="${dir:-$HOME/Vídeos/youtube-videos}"; local args=(-f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]" --merge-output-format mp4 --embed-thumbnail --add-metadata -o "$dir/%(title)s.%(ext)s") ;;
        music|m|audio|a) dir="${dir:-$HOME/Música}"; local args=(-x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata -o "$dir/%(title)s.%(ext)s") ;;
        playlist|p) download "${2:-video}" "$3" "$4"; return $? ;;
        *) echo "❌ Usa: video, music o playlist"; return 1 ;;
    esac

    mkdir -p "$dir"
    echo "⬇️ Descargando en: $dir"
    local final_cmd=(yt-dlp "${args[@]}")
    [[ -f "$HOME/.config/yt-dlp/cookies.txt" ]] && final_cmd+=(--cookies "$HOME/.config/yt-dlp/cookies.txt")
    "${final_cmd[@]}" "$url" && echo "✅ ¡Completado!" || echo "⚠️ Falló la descarga."
}

function verify-hash() {
    [[ "$1" == "-h" ]] && { echo "Uso: verify-hash calculate <archivo> [algo] | verify-hash compare <archivo> <hash> [algo]"; return 0; }
    local action="$1" file="$2" expected="$3" algo="$4"
    local RED='\033[0;31m' GREEN='\033[0;32m' BLUE='\033[0;34m' NC='\033[0m'

    _calc() {
        local cmd; case "$2" in md5) cmd="md5sum";; sha1) cmd="sha1sum";; sha256) cmd="sha256sum";; sha512) cmd="sha512sum";; *) cmd="sha256sum";; esac
        $cmd "$1" 2>/dev/null | awk '{print $1}'
    }

    [[ ! -f "$file" ]] && { echo -e "${RED}❌ Archivo no existe${NC}"; return 1; }

    if [[ "$action" == "calculate" || "$action" == "calc" || "$action" == "c" ]]; then
        algo="${expected:-sha256}"
        local hash=$(_calc "$file" "$algo")
        echo -e "${BLUE}📊 Hash ($algo):${NC}\n$hash"
    elif [[ "$action" == "compare" || "$action" == "comp" || -n "$expected" ]]; then
        [[ "$action" != "compare" && "$action" != "comp" ]] && { file="$1"; expected="$2"; algo="$3"; }
        local hash=$(_calc "$file" "${algo:-sha256}")
        [[ "$hash" == "$expected" ]] && echo -e "${GREEN}✅ ¡VERIFICACIÓN EXITOSA!${NC}" || echo -e "${RED}❌ ¡HASH NO COINCIDE!${NC}\nEsperado: $expected\nCalculado: $hash"
    else
        echo "Uso: verify-hash calculate <archivo> | verify-hash compare <archivo> <hash>"
    fi
}

function vm() {
    [[ "$1" == "-h" ]] && { echo "Uso: vm <create|run|full> [args...]"; return 0; }
    command -v qemu-system-x86_64 &>/dev/null || { echo "❌ Instala QEMU"; return 1; }
    local action="$1"; shift
    case "$action" in
        create) [[ -z "$2" ]] && { echo "Uso: vm create <archivo> <tamaño>"; return 1; }; qemu-img create -f qcow2 "$1" "$2" ;;
        run)
            local ram="$1" cpus="$2" disco="$3" iso="$4" usb="$5"
            [[ -z "$disco" ]] && { echo "Uso: vm run <RAM> <CPUs> <disco.qcow2> [iso] [usb_id]"; return 1; }
            [[ "$disco" == *.iso && -n "$iso" && "$iso" != *.iso ]] && { local t="$disco"; disco="$iso"; iso="$t"; }
            local kvm=(); [[ -w /dev/kvm ]] && kvm=(-enable-kvm -cpu host) || kvm=(-cpu qemu64)
            local usb_args=(-device qemu-xhci)
            [[ -n "$usb" ]] && { local v=${usb%:*} p=${usb#*:}; usb_args=(-device qemu-xhci,id=usb -device usb-host,vendorid=0x$v,productid=0x$p); echo "🔌 USB: $usb"; }
            local args=(qemu-system-x86_64 -M q35 "${kvm[@]}" -m "$ram" -smp "$cpus" -drive file="$disco",format=qcow2 -netdev user,id=net -device e1000,netdev=net -vga std "${usb_args[@]}" -device usb-tablet)
            [[ -n "$iso" && -f "$iso" ]] && args+=(-cdrom "$iso" -boot d) || args+=(-boot c)
            [[ -n "$usb" ]] && sudo "${args[@]}" || "${args[@]}" ;;
        full) qemu-img create -f qcow2 "$1" "$2"; vm run "$3" "$4" "$1" "$5" ;;
        *) echo "Comandos: create, run, full" ;;
    esac
}