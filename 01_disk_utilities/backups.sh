#!/usr/bin/env zsh

# --- CONFIGURACIÓN ---
REAL_USER=${SUDO_USER:-$USER}
SOURCE="/home/$REAL_USER/"
TARGET="/run/media/senseikatana/TIMEMACHINE"
LAST_BACKUP="$TARGET/latest"
CURRENT_BACKUP="$TARGET/backup_$(date +%Y%m%d_%H%M%S)"

# --- VALIDACIÓN DE DISCO ---
# Comprobamos si el punto de montaje es de solo lectura
if [[ -d "/run/media/senseikatana/TIMEMACHINE" ]]; then
    if [[ ! -w "/run/media/senseikatana/TIMEMACHINE" ]]; then
        echo "❌ ERROR: El disco está en modo LECTURA (Read-Only). Intenta remontarlo."
        exit 1
    fi
else
    echo "❌ ERROR: El disco no está montado."
    exit 1
fi

mkdir -p "$TARGET"

echo "--- 📂 Iniciando Backup para: $REAL_USER ---"

# --- CONFIGURACIÓN DE EXCLUSIONES ---
# Definimos los patrones en un array para evitar errores de parseo
EXCLUDES=(
    --exclude='.cache'
    --exclude='Downloads'
    --exclude='MEGA'
    --exclude='nextcloud'
    --exclude='works'
    --exclude='Trash'
    --exclude='.local/share/Trash'
    --exclude='node_modules'
    --exclude='virt-manager'
    --exclude='go'
    --exclude='Vaults'
)

# --- EJECUCIÓN RSYNC ---
if [ -d "$LAST_BACKUP" ]; then
    echo "🔄 Usando backup anterior como referencia..."
    rsync -aHAXvh --delete "${EXCLUDES[@]}" --link-dest="$LAST_BACKUP" "$SOURCE" "$CURRENT_BACKUP"
else
    echo "🆕 Primer backup detectado, esto podría tardar..."
    rsync -aHAXvh "${EXCLUDES[@]}" "$SOURCE" "$CURRENT_BACKUP"
fi

# --- RESULTADO Y NUBE ---
if [ $? -eq 0 ]; then
    rm -f "$LAST_BACKUP"
    ln -s "$CURRENT_BACKUP" "$LAST_BACKUP"
    echo "✅ Backup local finalizado con ÉXITO."

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
fi