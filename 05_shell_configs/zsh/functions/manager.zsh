# ==============================================
# 📋 GESTOR Y LISTADO DE FUNCIONES PERSONALIZADAS
# ==============================================

# Print a beautiful directory listing details and usage tips for all available custom Dojo helper shell functions.
# Uses 'gum' formatting when available for enhanced visuals.
#
# Return:
#   0 on success
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