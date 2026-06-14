#!/usr/bin/env zsh
# ============================================================================
# RESCUE - Sistema de Diagnóstico y Recuperación de Emergencia para Linux
# Compatible con Zsh y Bash
# Instalación: ./rescue --install
# ============================================================================

# Detectar si el script está siendo ejecutado directamente (compatible Zsh/Bash)
if [[ "${ZSH_EVAL_CONTEXT:-}" = "toplevel" ]] || [[ "${BASH_SOURCE[0]:-}" = "${0}" ]] || [[ "$0" = *rescue* && "$_" != *source* ]]; then
    # Ejecutando como script
    RUNNING_AS_SCRIPT=true
else
    # Siendo sourceado
    RUNNING_AS_SCRIPT=false
fi

# Solo configurar opciones estrictas si se ejecuta como script
if [[ "$RUNNING_AS_SCRIPT" = true ]]; then
    # Configuración específica según shell
    if [[ -n "$ZSH_VERSION" ]]; then
        setopt ERR_EXIT NO_UNSET PIPE_FAIL 2>/dev/null || true
    elif [[ -n "$BASH_VERSION" ]]; then
        set -euo pipefail
    fi
fi

# Configuración de rutas
readonly RESCUE_CONFIG_DIR="${HOME}/.config/rescue"
readonly RESCUE_CORE="${RESCUE_CONFIG_DIR}/core.sh"
readonly RESCUE_ALIASES="${RESCUE_CONFIG_DIR}/aliases.zsh"

# Colores
readonly COLOR_INFO='\033[0;36m'
readonly COLOR_SUCCESS='\033[0;32m'
readonly COLOR_WARNING='\033[1;33m'
readonly COLOR_ERROR='\033[0;31m'
readonly COLOR_RESET='\033[0m'

# ============================================================================
# FUNCIONES DE INSTALACIÓN
# ============================================================================
install_rescue() {
    echo -e "${COLOR_INFO}╔═══════════════════════════════════════════════════════════════╗${COLOR_RESET}"
    echo -e "${COLOR_INFO}║           🛟  INSTALACIÓN DE RESCUE                            ║${COLOR_RESET}"
    echo -e "${COLOR_INFO}╚═══════════════════════════════════════════════════════════════╝${COLOR_RESET}"
    echo ""

    # Detectar usuario real (incluso con sudo)
    local real_user="${SUDO_USER:-$USER}"
    local real_home
    if [[ -n "$SUDO_USER" ]]; then
        real_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    else
        real_home="$HOME"
    fi
    
    local config_dir="${real_home}/.config/rescue"
    local bin_dir="${real_home}/.local/bin"

    # Crear directorios
    echo -e "${COLOR_WARNING}📁 Creando estructura de directorios...${COLOR_RESET}"
    mkdir -p "$config_dir"
    mkdir -p "$bin_dir"
    
    # Corregir permisos si es sudo
    if [[ -n "$SUDO_USER" ]]; then
        chown -R "$real_user:$real_user" "$config_dir"
        chown -R "$real_user:$real_user" "$bin_dir"
    fi

    # Crear archivo core
    echo -e "${COLOR_WARNING}🔧 Creando módulo principal...${COLOR_RESET}"
    create_core_module "$config_dir"

    # Copiar script a ~/.local/bin
    echo -e "${COLOR_WARNING}📋 Instalando ejecutable...${COLOR_RESET}"
    cp "$0" "${bin_dir}/rescue"
    chmod +x "${bin_dir}/rescue"
    
    if [[ -n "$SUDO_USER" ]]; then
        chown "$real_user:$real_user" "${bin_dir}/rescue"
    fi

    # Agregar a PATH si es necesario
    if [[ ":$PATH:" != *":${bin_dir}:"* ]]; then
        echo -e "${COLOR_WARNING}⚠️  Agregando ~/.local/bin a PATH...${COLOR_RESET}"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${real_home}/.zshrc"
    fi

    # Crear aliases
    create_aliases_file "$config_dir" "$real_home"

    # Agregar source a .zshrc
    if ! grep -q "rescue/aliases.zsh" "${real_home}/.zshrc" 2>/dev/null; then
        echo "" >> "${real_home}/.zshrc"
        echo "# Rescue - Herramientas de emergencia del sistema" >> "${real_home}/.zshrc"
        echo "[ -f ~/.config/rescue/aliases.zsh ] && source ~/.config/rescue/aliases.zsh" >> "${real_home}/.zshrc"
    fi

    echo ""
    echo -e "${COLOR_SUCCESS}✅ Instalación completada exitosamente!${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_INFO}📖 Comandos disponibles:${COLOR_RESET}"
    echo -e "  ${COLOR_SUCCESS}system-diagnose${COLOR_RESET}     - Diagnóstico completo del sistema"
    echo -e "  ${COLOR_SUCCESS}system-quick-check${COLOR_RESET}  - Verificación rápida de recursos"
    echo -e "  ${COLOR_SUCCESS}emergency-help${COLOR_RESET}       - Guía para sistema congelado (REISUB)"
    echo -e "  ${COLOR_SUCCESS}clear-ram-cache${COLOR_RESET}      - Liberar caché de memoria RAM"
    echo -e "  ${COLOR_SUCCESS}top-resources${COLOR_RESET}        - Ver procesos que más consumen"
    echo ""
    echo -e "${COLOR_WARNING}🔄 Reinicia tu terminal o ejecuta: source ~/.zshrc${COLOR_RESET}"
}

create_core_module() {
    local config_dir="$1"
    cat > "${config_dir}/core.zsh" << 'CORE_EOF'
#!/usr/bin/env zsh
# ============================================================================
# RESCUE CORE - Módulo de diagnóstico del sistema
# ============================================================================

autoload -U colors && colors

readonly CPU_WARNING=70
readonly RAM_WARNING=80
readonly RAM_CRITICAL=90
readonly SWAP_WARNING=50

detect_distribution() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        case "$ID" in
            arch|manjaro|endeavouros|garuda|artix) echo "arch" ;;
            debian|ubuntu|linuxmint|pop|kali|mx)   echo "debian" ;;
            fedora|rhel|centos|rocky|almalinux)    echo "rhel" ;;
            opensuse*)                              echo "suse" ;;
            *)                                      echo "$ID" ;;
        esac
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    else
        echo "unknown"
    fi
}

analyze_memory() {
    local mem_total=$(awk '/MemTotal/ {printf "%.0f", $2/1024}' /proc/meminfo)
    local mem_available=$(awk '/MemAvailable/ {printf "%.0f", $2/1024}' /proc/meminfo)
    local mem_used=$((mem_total - mem_available))
    local usage_percent=$((mem_used * 100 / mem_total))
    
    echo "${fg_bold[default]}📊 Memoria RAM:${reset_color}"
    echo "  Total:        ${fg[cyan]}${mem_total} MB${reset_color}"
    
    if [[ $usage_percent -ge $RAM_CRITICAL ]]; then
        echo "  En uso:       ${fg[red]}${mem_used} MB (${usage_percent}%)${reset_color}"
        echo "\n${fg[red]}🚨 CRÍTICO: Memoria RAM agotada${reset_color}"
        echo "${fg[yellow]}   Recomendación: Ejecuta 'clear-ram-cache' o cierra aplicaciones${reset_color}"
    elif [[ $usage_percent -ge $RAM_WARNING ]]; then
        echo "  En uso:       ${fg[yellow]}${mem_used} MB (${usage_percent}%)${reset_color}"
        echo "\n${fg[yellow]}⚠️  Advertencia: Memoria RAM alta${reset_color}"
    else
        echo "  En uso:       ${fg[green]}${mem_used} MB (${usage_percent}%)${reset_color}"
    fi
    
    echo "  Disponible:   ${fg[green]}${mem_available} MB${reset_color}"
    
    # Barra visual
    local bar_width=30
    local filled=$((usage_percent * bar_width / 100))
    local empty=$((bar_width - filled))
    
    echo -n "  ["
    for ((i=0; i<filled; i++)); do echo -n "█"; done
    for ((i=0; i<empty; i++)); do echo -n "░"; done
    echo "] ${usage_percent}%"
}

analyze_swap() {
    local swap_total=$(awk '/SwapTotal/ {printf "%.0f", $2/1024}' /proc/meminfo)
    local swap_free=$(awk '/SwapFree/ {printf "%.0f", $2/1024}' /proc/meminfo)
    local swap_used=$((swap_total - swap_free))
    
    if [[ $swap_total -eq 0 ]]; then
        echo "\n${fg_bold[default]}💾 Swap:${reset_color} ${fg[cyan]}No configurada${reset_color}"
        return
    fi
    
    local usage_percent=$((swap_used * 100 / swap_total))
    
    echo "\n${fg_bold[default]}💾 Swap:${reset_color}"
    echo "  Total:      ${fg[cyan]}${swap_total} MB${reset_color}"
    
    if [[ $usage_percent -ge $SWAP_WARNING ]]; then
        echo "  En uso:     ${fg[yellow]}${swap_used} MB (${usage_percent}%)${reset_color}"
        echo "  ${fg[yellow]}💡 Swap muy utilizada. Considera liberarla.${reset_color}"
    else
        echo "  En uso:     ${swap_used} MB (${usage_percent}%)"
    fi
}

analyze_load() {
    local load_1m=$(awk '{print $1}' /proc/loadavg)
    local load_5m=$(awk '{print $2}' /proc/loadavg)
    local load_15m=$(awk '{print $3}' /proc/loadavg)
    local cpu_count=$(nproc)
    
    echo "\n${fg_bold[default]}⚙️  Carga del Sistema:${reset_color}"
    echo "  CPUs:           ${fg[cyan]}${cpu_count}${reset_color}"
    echo "  Load Average:   ${load_1m} (1m) | ${load_5m} (5m) | ${load_15m} (15m)"
    
    if awk -v l="$load_1m" -v c="$cpu_count" 'BEGIN {exit !(l > c*2)}'; then
        echo "\n${fg[red]}🚨 CRÍTICO: Sistema extremadamente sobrecargado${reset_color}"
    elif awk -v l="$load_1m" -v c="$cpu_count" 'BEGIN {exit !(l > c)}'; then
        echo "\n${fg[yellow]}⚠️  Sistema con carga elevada${reset_color}"
    fi
}

analyze_processes() {
    echo "\n${fg_bold[default]}🔥 Procesos de Mayor Consumo:${reset_color}"
    
    echo "\n${fg[cyan]}Top 5 por CPU:${reset_color}"
    echo "  PID      USUARIO    CPU%   MEM%   COMANDO"
    ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu 2>/dev/null | head -6 | tail -5 | \
        awk '{printf "  %-8s %-10s %5s  %5s  %s\n", $1, $2, $3"%", $4"%", $5}'
    
    echo "\n${fg[cyan]}Top 5 por Memoria:${reset_color}"
    echo "  PID      USUARIO    CPU%   MEM%   COMANDO"
    ps -eo pid,user,%cpu,%mem,comm --sort=-%mem 2>/dev/null | head -6 | tail -5 | \
        awk '{printf "  %-8s %-10s %5s  %5s  %s\n", $1, $2, $3"%", $4"%", $5}'
    
    # Zombies
    local zombies=$(ps aux 2>/dev/null | awk '$8 ~ /Z/ {count++} END {print count+0}')
    if [[ "$zombies" -gt 0 ]]; then
        echo "\n${fg[yellow]}👻 Procesos zombie: ${zombies}${reset_color}"
    fi
    
    # Estado D
    local d_procs=$(ps aux 2>/dev/null | awk '$8 ~ /D/ {count++} END {print count+0}')
    if [[ "$d_procs" -gt 0 ]]; then
        echo "${fg[yellow]}💾 Procesos bloqueados por I/O: ${d_procs}${reset_color}"
    fi
}

clear_memory_cache() {
    echo "${fg[yellow]}🧹 Liberando caché de memoria...${reset_color}"
    sync
    
    if [[ $EUID -eq 0 ]]; then
        echo 3 > /proc/sys/vm/drop_caches
    else
        echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null 2>&1
    fi
    
    echo "${fg[green]}✓ Caché liberada correctamente${reset_color}"
}

full_diagnostic() {
    clear
    echo "${fg_bold[default]}╔════════════════════════════════════════════════════════════════╗${reset_color}"
    echo "${fg_bold[default]}║              🔍 DIAGNÓSTICO COMPLETO DEL SISTEMA                ║${reset_color}"
    echo "${fg_bold[default]}╚════════════════════════════════════════════════════════════════╝${reset_color}"
    echo ""
    
    echo "${fg[cyan]}Sistema:${reset_color} $(detect_distribution) | Kernel: $(uname -r)"
    echo "${fg[cyan]}Uptime:${reset_color} $(uptime -p 2>/dev/null || echo "N/A")"
    echo "${fg[cyan]}Usuario:${reset_color} $USER"
    echo ""
    
    analyze_memory
    analyze_swap
    analyze_load
    analyze_processes
}

quick_check() {
    clear
    echo "${fg_bold[default]}📊 Verificación Rápida de Recursos${reset_color}"
    echo ""
    analyze_memory
    echo ""
    analyze_load
    echo ""
    
    echo "${fg_bold[default]}Top 3 procesos por CPU:${reset_color}"
    ps -eo pid,user,%cpu,comm --sort=-%cpu 2>/dev/null | head -4 | tail -3
}

display_emergency_help() {
    echo "${fg_bold[default]}╔════════════════════════════════════════════════════════════════╗${reset_color}"
    echo "${fg_bold[default]}║           🚨 GUÍA DE EMERGENCIA - SISTEMA CONGELADO            ║${reset_color}"
    echo "${fg_bold[default]}╚════════════════════════════════════════════════════════════════╝${reset_color}"
    echo ""
    echo "${fg[red]}${fg_bold[default]}CUANDO NADA RESPONDE (ni ratón, ni teclado):${reset_color}"
    echo ""
    echo "${fg_bold[default]}🔑 SECUENCIA REISUB (Reinicio Seguro)${reset_color}"
    echo "${fg[yellow]}─────────────────────────────────────────${reset_color}"
    echo "  1. Mantén presionado: ${fg[cyan]}Alt + SysRq (Print Screen)${reset_color}"
    echo "  2. Presiona en orden (pausa 1-2 seg entre cada una):"
    echo ""
    echo "     ${fg[green]}R${reset_color} → Recuperar control del teclado (Raw)"
    echo "     ${fg[green]}E${reset_color} → Terminar procesos limpiamente (tErminate)"
    echo "     ${fg[green]}I${reset_color} → Forzar cierre de procesos (kIll)"
    echo "     ${fg[green]}S${reset_color} → Sincronizar discos (Sync)"
    echo "     ${fg[green]}U${reset_color} → Desmontar sistemas de archivos (Unmount)"
    echo "     ${fg[green]}B${reset_color} → Reiniciar sistema (reBoot)"
    echo ""
    echo "  ${fg[cyan]}Nemotecnia:${reset_color} \"R-E-I-S-U-B\" = \"REInicia SUave y Básico\""
    echo ""
    echo "${fg_bold[default]}🔧 VERIFICAR DISPONIBILIDAD${reset_color}"
    echo "  cat /proc/sys/kernel/sysrq"
    echo "  Debe mostrar: ${fg[green]}1${reset_color} (activado) o mayor"
    echo ""
    echo "${fg[yellow]}Para activar permanentemente:${reset_color}"
    echo "  echo 'kernel.sysrq=1' | sudo tee /etc/sysctl.d/99-sysrq.conf"
}
CORE_EOF
    chmod +x "${config_dir}/core.zsh"
}

create_aliases_file() {
    local config_dir="$1"
    local real_home="$2"
    
    cat > "${config_dir}/aliases.zsh" << 'ALIASES_EOF'
# ============================================================================
# RESCUE - Aliases de emergencia del sistema (Zsh)
# ============================================================================

# Source del core
[ -f ~/.config/rescue/core.zsh ] && source ~/.config/rescue/core.zsh

# Aliases principales
alias system-diagnose='full_diagnostic'
alias system-quick-check='quick_check'
alias emergency-help='display_emergency_help'
alias clear-ram-cache='clear_memory_cache'
alias top-resources='ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -15'
alias what-uses-cpu='ps -eo pid,user,%cpu,comm --sort=-%cpu | head -15'
alias check-zombies='ps aux | awk '\''$8 ~ /Z/ {print $2, $11}'\'''
alias check-dstate='ps aux | awk '\''$8 ~ /D/ {print $2, $11}'\'''

# Función para ver OOM score
show-oom-score() {
    echo "Procesos con mayor probabilidad de ser eliminados por OOM:"
    for pid in /proc/[0-9]*; do
        if [ -f "$pid/oom_score" ]; then
            score=$(cat "$pid/oom_score" 2>/dev/null)
            p=${pid##*/}
            cmd=$(cat "$pid/cmdline" 2>/dev/null | tr '\0' ' ' | cut -c1-40)
            [ -n "$score" ] && [ "$score" -gt 0 ] && echo "$score $p $cmd"
        fi
    done | sort -rn | head -10 | while read s p c; do
        printf "%6s  PID %-6s  %s\n" "$s" "$p" "$c"
    done
}
ALIASES_EOF
}

show_help() {
    cat << EOF
${COLOR_INFO}🛟  RESCUE - Sistema de Recuperación de Emergencia para Linux${COLOR_RESET}

${COLOR_BOLD}USO:${COLOR_RESET}
  rescue [OPCIÓN]

${COLOR_BOLD}OPCIONES:${COLOR_RESET}
  --install           Instalar rescue en el sistema
  --diagnose, -d      Diagnóstico completo del sistema
  --quick, -q         Verificación rápida de recursos
  --emergency, -e     Mostrar guía de emergencia REISUB
  --clear-cache, -c   Limpiar caché de memoria RAM
  --help, -h          Mostrar esta ayuda

${COLOR_BOLD}EJEMPLOS:${COLOR_RESET}
  ./rescue --install      # Instalar en el sistema
  rescue --diagnose       # Diagnóstico completo
EOF
}

main() {
    case "${1:-}" in
        --install)
            install_rescue
            ;;
        --diagnose|-d)
            if [[ -f "$RESCUE_CORE" ]]; then
                source "$RESCUE_CORE"
                full_diagnostic
            else
                echo -e "${COLOR_ERROR}❌ Rescue no está instalado${COLOR_RESET}"
                echo -e "Ejecuta: ${COLOR_WARNING}$0 --install${COLOR_RESET}"
                return 1
            fi
            ;;
        --quick|-q)
            if [[ -f "$RESCUE_CORE" ]]; then
                source "$RESCUE_CORE"
                quick_check
            else
                echo -e "${COLOR_ERROR}❌ Rescue no está instalado${COLOR_RESET}"
                echo -e "Ejecuta: ${COLOR_WARNING}$0 --install${COLOR_RESET}"
                return 1
            fi
            ;;
        --emergency|-e)
            if [[ -f "$RESCUE_CORE" ]]; then
                source "$RESCUE_CORE"
                display_emergency_help
            else
                echo -e "${COLOR_ERROR}❌ Rescue no está instalado${COLOR_RESET}"
                echo -e "Ejecuta: ${COLOR_WARNING}$0 --install${COLOR_RESET}"
                return 1
            fi
            ;;
        --clear-cache|-c)
            if [[ -f "$RESCUE_CORE" ]]; then
                source "$RESCUE_CORE"
                clear_memory_cache
            else
                echo -e "${COLOR_ERROR}❌ Rescue no está instalado${COLOR_RESET}"
                echo -e "Ejecuta: ${COLOR_WARNING}$0 --install${COLOR_RESET}"
                return 1
            fi
            ;;
        --help|-h|"")
            show_help
            ;;
        *)
            echo -e "${COLOR_ERROR}❌ Opción desconocida: $1${COLOR_RESET}"
            show_help
            return 1
            ;;
    esac
}

# Solo ejecutar main si NO está siendo sourceado
if [[ "${ZSH_EVAL_CONTEXT:-}" = "toplevel" ]] || [[ "${BASH_SOURCE[0]:-}" = "${0}" ]]; then
    main "$@"
fi