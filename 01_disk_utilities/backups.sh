#!/usr/bin/env zsh

# --- CONFIGURACIÓN ---
REAL_USER=${SUDO_USER:-$USER}
SOURCE="/home/$REAL_USER/"
TARGET="/run/media/senseikatana/TIMEMACHINE2"
LAST_BACKUP="$TARGET/latest"
CURRENT_BACKUP="$TARGET/backup_$(date +%Y%m%d_%H%M%S)"

echo "--- 🔍 Verificando estado del disco de destino ---"

# --- VALIDACIÓN DE DISCO ---
if [[ ! -d "$TARGET" ]]; then
    echo "❌ ERROR: El disco no está montado o la ruta base no existe."
    echo "Ruta buscada: $TARGET"
    exit 1
fi

# Comprobamos si el punto de montaje es de solo lectura
if [[ ! -w "$TARGET" ]]; then
    echo "⚠️ El disco está en modo LECTURA (Read-Only)."
    echo "🔄 Intentando remontar el disco automáticamente con permisos de escritura..."
    
    # Intenta remontar el disco
    mount -o remount,rw "$TARGET"
    
    # Volvemos a comprobar si funcionó el remonte
    if [[ ! -w "$TARGET" ]]; then
        echo "❌ ERROR CRÍTICO: No se pudo remontar en modo escritura."
        echo "💡 Posible causa: Si el disco es NTFS (Windows), puede tener errores o estar hibernado."
        echo "💡 Solución manual: Ejecuta 'sudo ntfsfix /dev/sdX' (cambia sdX por tu disco)."
        exit 1
    else
        echo "✅ Disco remontado en modo escritura con éxito."
    fi
fi

echo "--- 📂 Iniciando Backup para: $REAL_USER ---"

# --- CONFIGURACIÓN DE EXCLUSIONES ---
EXCLUDES=(
    --exclude='.cache'
    --exclude='Downloads'
    --exclude='MEGA'
    --exclude='works'
    --exclude='Trash'
    --exclude='.local/share/Trash'
    --exclude='node_modules'
    --exclude='virt-manager'
    --exclude='go'
    --exclude='antigravity'
    --exclude='Github'
    --exclude='Gitlab'
    --exclude='DockerVM'
    --exclude='Internxt Drive'
)

# --- EJECUCIÓN RSYNC ---
if [ -d "$LAST_BACKUP" ]; then
    echo "🔄 Usando backup anterior como referencia (Hardlinks para ahorrar espacio)..."
    rsync -aHAXvh --delete "${EXCLUDES[@]}" --link-dest="$LAST_BACKUP" "$SOURCE" "$CURRENT_BACKUP"
else
    echo "🆕 Primer backup detectado en el disco de 1TB, esto podría tardar..."
    rsync -aHAXvh "${EXCLUDES[@]}" "$SOURCE" "$CURRENT_BACKUP"
fi

# --- RESULTADO Y NUBE ---
if [ $? -eq 0 ]; then
    # Actualizar el enlace simbólico al último backup
    rm -f "$LAST_BACKUP"
    ln -s "$CURRENT_BACKUP" "$LAST_BACKUP"
    echo "✅ Backup local finalizado con ÉXITO en:"
    echo "   📁 $CURRENT_BACKUP"

    # --- SUBIDA A INTERNXT ---
    if command -v internxt &> /dev/null; then
        echo "☁️ Subiendo a Internxt Drive..."
        # Nota: Asegúrate de haber hecho 'internxt login' previamente
        internxt upload --directory "$CURRENT_BACKUP" --to "Backups_Linux"
    else
        echo "⚠️ Internxt CLI no instalado. Saltando subida a la nube."
    fi
else
    echo "❌ ERROR durante el rsync. Revisa los permisos de los archivos origen."
    # Si falla, borramos el directorio a medias para no dejar basura
    rm -rf "$CURRENT_BACKUP"
    exit 1
fi