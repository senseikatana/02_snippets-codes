# ==============================================
# 📦 GESTORES DE PAQUETES
# ==============================================
function pkg() {
    [[ "$1" == "-h" ]] && { echo "Uso: pkg <i|r|u|c|k|conf> [paquete]"; return 0; }
    case "$1" in
        i|install) shift; [[ -z "$1" ]] && { echo "❌ Especifica un paquete"; return 1; }; yay -S --noconfirm "$@" ;;
        r|remove) shift; [[ -z "$1" ]] && { echo "❌ Especifica un paquete"; return 1; }; yay -Rns --noconfirm "$@" ;;
        u|update) echo "🚀 Actualizando..."; yay -Syyu --noconfirm; command -v flatpak &>/dev/null && flatpak update -y; pkg c ;;
        c|clean) echo "🧹 Limpiando..."; sudo pacman -Sc --noconfirm; local orphans=$(pacman -Qdtq); [[ -n "$orphans" ]] && sudo pacman -Rs $orphans --noconfirm || echo "✨ Sin huérfanos." ;;
        k|keys) echo "🔑 Sincronizando llaves..."; sudo pacman-key --init; sudo pacman-key --populate archlinux; sudo pacman -Sy archlinux-keyring --noconfirm ;;
        conf) sudo EDITOR="${EDITOR:-nano}" /etc/pacman.conf ;;
        *) echo "📦 pkg: i (instalar), r (remover), u (actualizar), c (limpiar), k (llaves), conf (editar)" ;;
    esac
}

function pkg-deb() {
    [[ "$1" == "-h" ]] && { echo "Uso: pkg-deb <i|r|u|c|s> [paquete]"; return 0; }
    local pm; command -v nala &> /dev/null && pm="nala" || pm="apt"
    case "$1" in
        i|install) shift; [[ -z "$1" ]] && { echo "❌ Especifica un paquete"; return 1; }; sudo $pm install -y "$@" ;;
        r|remove) shift; [[ -z "$1" ]] && { echo "❌ Especifica un paquete"; return 1; }; sudo $pm autoremove --purge -y "$@" ;;
        u|update) echo "🚀 Actualizando con $pm..."; sudo $pm update && sudo $pm upgrade -y; pkg-deb c ;;
        c|clean) echo "🧹 Limpiando..."; sudo $pm autoremove -y && sudo $pm autoclean; [[ "$pm" == "nala" ]] && sudo nala clean || sudo apt clean ;;
        s|search) shift; [[ -z "$1" ]] && { echo "❌ Especifica qué buscar"; return 1; }; $pm search "$@" ;;
        *) echo "📦 pkg-deb ($pm): i (instalar), r (remover), u (actualizar), c (limpiar), s (buscar)" ;;
    esac
}