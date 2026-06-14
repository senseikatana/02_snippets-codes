# ==============================================
# 📋 GESTOR Y LISTADO DE FUNCIONES PERSONALIZADAS
# ==============================================
function zfuncs() {
    if command -v gum &>/dev/null; then
        gum style --border double --border-foreground 57 --foreground 212 \
            --padding "1 2" --margin "1" "🥷 FUNCIONES DEL DOJO DISPONIBLES"
    else
        echo -e "\n\e[1;35m🥷 FUNCIONES DEL DOJO DISPONIBLES\e[0m\n"
    fi

    echo -e "  \e[1;36m📊 sysinfo\e[0m       : Info del sistema. Uso: \e[33msysinfo -a\e[0m (o -u, -k, -f, -n, -d, -hw, -s, -x)"
    echo -e "  \e[1;36m📦 pkg\e[0m            : Gestor unificado Arch/AUR. Uso: \e[33mpkg i <paquete>\e[0m, \e[33mpkg u\e[0m, \e[33mpkg c\e[0m"
    echo -e "  \e[1;36m📦 pkg-deb\e[0m        : Gestor unificado Debian/Ubuntu. Uso: \e[33mpkg-deb i <paquete>\e[0m"
    echo -e "  \e[1;36m🛠️  create-web\e[0m     : Andamiaje web con Bun. Uso: \e[33mcreate-web vite mi-proyecto\e[0m"
    echo -e "  \e[1;36m⬇️  download\e[0m       : Descargas yt-dlp. Uso: \e[33mdownload video <url>\e[0m (o music, playlist)"
    echo -e "  \e[1;36m🔐 verify-hash\e[0m    : Integridad de archivos. Uso: \e[33mverify-hash calculate <archivo>\e[0m"
    echo -e "  \e[1;36m💻 vm\e[0m            : Máquinas virtuales QEMU. Uso: \e[33mvm run 4G 2 disco.qcow2\e[0m"
    echo -e "  \e[1;36m🐙 gcm / gac\e[0m      : Commits inteligentes con contexto automático y Gum"
    echo -e "  \e[1;36m📋 list-apps\e[0m      : Busca apps instaladas. Uso: \e[33mlist-apps [nombre]\e[0m"

    echo -e "\n  \e[1;33m💡 Tip: Escribe \`<comando> -h\` para ver la ayuda detallada de cada función.\e[0m\n"
}