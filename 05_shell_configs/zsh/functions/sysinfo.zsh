# ==============================================
# 🖥️ INFORMACIÓN DEL SISTEMA
# ==============================================
function sysinfo() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && { echo "Uso: sysinfo [-u|-k|-f|-n|-d|-hw|-s|-x|-a]"; return 0; }

    local CB="\e[1;35m" CT="\e[1;36m" CK="\e[1;33m" CV="\e[0m"
    _print_header() { echo -e "\n${CT}=== $1 ===${CV}"; printf "${CB}┌─%-35s─┬─%-65s─┐${CV}\n" "───" "───"; printf "${CB}│${CT} %-35s ${CB}│${CT} %-65s ${CB}│${CV}\n" "$2" "$3"; printf "${CB}├─%-35s─┼─%-65s─┤${CV}\n" "───" "───"; }
    _print_row() { printf "${CB}│${CK} %-35.35s ${CB}│${CV} %-65.65s ${CB}│${CV}\n" "$1" "$2"; }
    _print_footer() { printf "${CB}└─%-35s─┴─%-65s─┘${CV}\n" "───" "───"; }

    case "$1" in
        -u|--user) _print_header "USUARIO" "ATRIBUTO" "VALOR"; _print_row "Usuario" "$(whoami)"; _print_row "UID/GID" "$(id -u)/$(id -g)"; _print_row "Grupos" "$(id -Gn | tr ' ' ', ')"; _print_footer ;;
        -k|--kernel) _print_header "SISTEMA" "COMPONENTE" "DETALLE"; _print_row "Hostname" "$(hostname)"; _print_row "Distribución" "$(grep '^PRETTY_NAME=' /etc/os-release | cut -d '"' -f2)"; _print_row "Kernel" "$(uname -r)"; _print_footer ;;
        -f|--fetch) _print_header "RESUMEN (FASTFETCH)" "MÉTRICA" "VALOR"; fastfetch --logo none -s OS:Host:Kernel:Uptime:Packages:Shell:CPU:GPU:Memory:Disk 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | while IFS=':' read -r k v; do [[ -n "$k" ]] && _print_row "$(echo $k | xargs)" "$(echo $v | xargs)"; done; _print_footer ;;
        -n|--net) _print_header "RED" "INTERFAZ" "ESTADO / IP"; ip -br addr show | grep -vE "^(lo|tailscale|docker|veth|br-)" | while read -r i s ip; do _print_row "$i" "$s | $ip"; done; _print_footer ;;
        -d|--disk) _print_header "DISCOS" "PARTICIÓN" "TAMAÑO | FORMATO | MONTAJE"; lsblk -p -o NAME,SIZE,FSTYPE,MOUNTPOINT -n -r | grep -v "loop" | while read -r n s f m; do _print_row "$n" "$s | ${f:--} | ${m:--}"; done; _print_footer ;;
        -hw|--hardware) _print_header "HARDWARE" "COMPONENTE" "ESPECIFICACIÓN"; _print_row "CPU" "$(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"; _print_row "RAM" "$(free -h | awk '/^Mem:/ {print $2}')"; _print_row "GPU" "$(lspci 2>/dev/null | grep -i 'vga\|3d\|display' | head -1 | cut -d: -f3 | xargs)"; _print_footer ;;
        -s|--software) _print_header "SOFTWARE" "GESTOR" "ESTADO"; _print_row "Pacman" "$(pacman -Qq 2>/dev/null | wc -l) paquetes"; command -v flatpak &>/dev/null && _print_row "Flatpak" "$(flatpak list --app 2>/dev/null | wc -l) apps"; _print_footer ;;
        -x|--status) _print_header "SALUD" "MÉTRICA" "VALOR"; _print_row "RAM Usada" "$(free -h | awk '/^Mem:/ {print $3 " / " $2}')"; local fails=$(systemctl --failed --no-legend | wc -w); _print_row "Servicios Fallidos" "$fails"; _print_footer ;;
        -a|--all) sysinfo -u; sysinfo -k; sysinfo -f; sysinfo -n; sysinfo -d; sysinfo -hw; sysinfo -s; sysinfo -x ;;
        *) echo -e "\e[1;36m📊 sysinfo\e[0m: Muestra información del sistema."; echo "Uso: sysinfo [-u|-k|-f|-n|-d|-hw|-s|-x|-a]"; echo "  -a: Muestra todo. -h: Ayuda." ;;
    esac
}

function list-apps() {
    [[ "$1" == "-h" ]] && { echo "Uso: list-apps [nombre_a_buscar]"; return 0; }
    local q="$1"
    echo -e "\e[1;34m🔍 Buscando aplicaciones...\e[0m"
    echo -e "\n\e[1;33m🐧 Nativos:\e[0m"; [[ -z "$q" ]] && pacman -Qe --quiet | sort || pacman -Qe --quiet | grep -i "$q"
    command -v flatpak &>/dev/null && { echo -e "\n\e[1;33m📦 Flatpak:\e[0m"; [[ -z "$q" ]] && flatpak list --app --columns=name | sort || flatpak list --app --columns=name | grep -i "$q"; }
    echo -e "\n\e[1;32m✅ Búsqueda completada.\e[0m"
}