# ==============================================
# 🖥️ INFORMACIÓN DEL SISTEMA
# ==============================================

# Retrieve and format system information metrics, user sessions, network interfaces, disk space, and hardware specs.
# Can display individual metrics or all details concurrently. Shows help by default when no arguments are provided.
#
# Arguments:
#   $1 - option: -u/--user, -k/--kernel, -n/--net, -d/--disk, -hw/--hardware,
#                -s/--software, -x/--status, -f/--fetch, -a/--all
#
# Return:
#   0 on success, 1 on invalid option
function sysinfo() {
    if [[ -z "$1" || "$1" == "-h" || "$1" == "--help" ]]; then 
        print -P "%F{cyan}Uso: sysinfo [opciones]%f"
        print "  -u, --user     : Detalles de usuario y grupos"
        print "  -k, --kernel   : Versión de OS, hostname y kernel"
        print "  -n, --net      : Interfaces de red y direcciones IP"
        print "  -d, --disk     : Layout de discos y puntos de montaje"
        print "  -hw, --hardware: CPU, memoria RAM total y tarjeta gráfica (GPU)"
        print "  -s, --software : Total de paquetes instalados (pacman/flatpak)"
        print "  -x, --status   : RAM en uso y servicios de systemd fallidos"
        print "  -f, --fetch    : Resumen del sistema (vía fastfetch)"
        print "  -a, --all      : Ejecutar y mostrar todas las métricas juntas"
        return 0
    fi

    local CB="\e[1;35m" CT="\e[1;36m" CK="\e[1;33m" CV="\e[0m"
    _print_header() { 
        print "\n${CT}=== $1 ===${CV}"
        printf "${CB}┌─%-35s─┬─%-65s─┐${CV}\n" "───" "───"
        printf "${CB}│${CT} %-35s ${CB}│${CT} %-65s ${CB}│${CV}\n" "$2" "$3"
        printf "${CB}├─%-35s─┼─%-65s─┤${CV}\n" "───" "───"
    }
    _print_row() { 
        printf "${CB}│${CK} %-35.35s ${CB}│${CV} %-65.65s ${CB}│${CV}\n" "$1" "$2" 
    }
    _print_footer() { 
        printf "${CB}└─%-35s─┴─%-65s─┘${CV}\n" "───" "───" 
    }

    case "$1" in
        -u|--user) 
            _print_header "USUARIO" "ATRIBUTO" "VALOR"
            _print_row "Usuario" "$(whoami)"
            _print_row "UID/GID" "$(id -u)/$(id -g)"
            _print_row "Grupos" "$(id -Gn | tr ' ' ', ')"
            _print_footer 
            ;;
        -k|--kernel) 
            _print_header "SISTEMA" "COMPONENTE" "DETALLE"
            _print_row "Hostname" "$(hostname)"
            _print_row "Distribución" "$(command grep '^PRETTY_NAME=' /etc/os-release | cut -d '"' -f2 2>/dev/null || echo 'Unknown')"
            _print_row "Kernel" "$(uname -r)"
            _print_footer 
            ;;
        -f|--fetch) 
            _print_header "RESUMEN (FASTFETCH)" "MÉTRICA" "VALOR"
            if command -v fastfetch &>/dev/null; then
                fastfetch --logo none -s OS:Host:Kernel:Uptime:Packages:Shell:CPU:GPU:Memory:Disk 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | while IFS=':' read -r k v; do 
                    [[ -n "$k" ]] && _print_row "$(echo $k | xargs)" "$(echo $v | xargs)"
                done
            else
                _print_row "fastfetch command" "Not installed"
            fi
            _print_footer 
            ;;
        -n|--net) 
            _print_header "RED" "INTERFAZ" "ESTADO / IP"
            if command -v ip &>/dev/null; then
                ip -br addr show | command grep -vE "^(lo|tailscale|docker|veth|br-)" | while read -r i s ip; do 
                    _print_row "$i" "$s | $ip"
                done
            else
                _print_row "ip command" "Not installed"
            fi
            _print_footer 
            ;;
        -d|--disk) 
            _print_header "DISCOS" "PARTICIÓN" "TAMAÑO | FORMATO | MONTAJE"
            if command -v lsblk &>/dev/null; then
                lsblk -p -o NAME,SIZE,FSTYPE,MOUNTPOINT -n -r | command grep -v "loop" | while read -r n s f m; do 
                    _print_row "$n" "$s | ${f:--} | ${m:--}"
                done
            else
                _print_row "lsblk command" "Not installed"
            fi
            _print_footer 
            ;;
        -hw|--hardware) 
            _print_header "HARDWARE" "COMPONENTE" "ESPECIFICACIÓN"
            _print_row "CPU" "$(command grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs 2>/dev/null || echo 'Unknown')"
            _print_row "RAM" "$(free -h | awk '/^Mem:/ {print $2}' 2>/dev/null || echo 'Unknown')"
            _print_row "GPU" "$(lspci 2>/dev/null | command grep -i 'vga\|3d\|display' | head -1 | cut -d: -f3 | xargs || echo 'Not detected')"
            _print_footer 
            ;;
        -s|--software) 
            _print_header "SOFTWARE" "GESTOR" "ESTADO"
            _print_row "Pacman" "$(pacman -Qq 2>/dev/null | wc -l 2>/dev/null || echo '0') paquetes"
            command -v flatpak &>/dev/null && _print_row "Flatpak" "$(flatpak list --app 2>/dev/null | wc -l) apps"
            _print_footer 
            ;;
        -x|--status) 
            _print_header "SALUD" "MÉTRICA" "VALOR"
            _print_row "RAM Usada" "$(free -h | awk '/^Mem:/ {print $3 " / " $2}' 2>/dev/null || echo 'Unknown')"
            local fails=$(systemctl --failed --no-legend | wc -w 2>/dev/null || echo '0')
            _print_row "Servicios Fallidos" "$fails"
            _print_footer 
            ;;
        -a|--all) 
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
            print -P "%F{red}❌ Error: Opción no válida. Usa 'sysinfo -h' para más detalles.%f"
            return 1
            ;;
    esac
}

# Search repositories and Flatpak for matching installed applications.
#
# Arguments:
#   $1 - query: App name substring to search for
#
# Return:
#   0 on success
function list-apps() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && { echo "Uso: list-apps [nombre_a_buscar]"; return 0; }
    local q="$1"
    echo -e "\e[1;34m🔍 Buscando aplicaciones...\e[0m"
    echo -e "\n\e[1;33m🐧 Nativos:\e[0m"; [[ -z "$q" ]] && pacman -Qe --quiet 2>/dev/null | sort || pacman -Qe --quiet 2>/dev/null | command grep -i "$q"
    command -v flatpak &>/dev/null && { echo -e "\n\e[1;33m📦 Flatpak:\e[0m"; [[ -z "$q" ]] && flatpak list --app --columns=name 2>/dev/null | sort || flatpak list --app --columns=name 2>/dev/null | command grep -i "$q"; }
    echo -e "\n\e[1;32m✅ Búsqueda completada.\e[0m"
}