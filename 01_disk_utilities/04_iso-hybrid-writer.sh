#!/usr/bin/env zsh

# ==============================================================================
# SCRIPT: usb-hybrid.sh
# DESCRIPCIÓN: Limpieza profunda (zerofill) + Grabación de ISO. Inteligente.
# ==============================================================================

ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
AZUL='\033[0;34m'
NC='\033[0m'

device=""
iso_path=""

uso() {
    echo -e "${AZUL}Uso:${NC} sudo $0 [--device /dev/sdx] [--file /ruta/imagen.iso]"
    exit 1
}

verificar_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${ROJO}Este script debe ejecutarse como root (sudo).${NC}"
        exit 1
    fi
}

verificar_dependencias() {
    for dep in pv eject lsblk wipefs; do
        if ! command -v "$dep" &> /dev/null; then
            echo -e "${ROJO}[!] Falta la dependencia '$dep'. Por favor, instálala antes de continuar.${NC}"
            exit 1 # Esto es vital para detener el script si hay un error
        fi
    done
}

finalizar_proceso() {
    local dev="$1"
    echo -e "\n${AZUL}Sincronizando datos de la ISO en disco...${NC}"
    sync
    
    local is_removable=$(lsblk -n -d -o RM "$dev" | tr -d ' ')
    local transport=$(lsblk -n -d -o TRAN "$dev" | tr -d ' ')

    if [[ "$is_removable" == "1" || "$transport" == "usb" ]]; then
        echo -e "${AZUL}Expulsando dispositivo externo...${NC}"
        eject "$dev" 2>/dev/null
        echo -e "${VERDE}¡Grabación finalizada! Ya puedes retirar la unidad.${NC}"
    else
        echo -e "${VERDE}¡Grabación finalizada en el disco interno '$dev'!${NC}"
    fi
    exit 0
}

seleccionar_dispositivo() {
    if [[ -n "$device" ]]; then return; fi
    echo -e "\n${AZUL}Dispositivos disponibles:${NC}"
    lsblk -d -o NAME,SIZE,MODEL,TRAN | grep -v "loop"
    echo ""
    read "device?Ingresa el dispositivo (ej: /dev/sdb): "
    [[ ! -b "$device" ]] && echo -e "${ROJO}Dispositivo inválido.${NC}" && exit 1
}


seleccionar_iso() {
    if [[ -n "$iso_path" ]]; then return; fi
    
    if command -v zenity &> /dev/null; then
        echo -e "\n${AZUL}Abriendo selector de archivos...${NC}"
        # Se añade --filename="$HOME/" para abrir en la carpeta del usuario
        iso_path=$(zenity --file-selection --title="Selecciona el archivo ISO" --filename="$HOME/" --file-filter="*.iso" 2>/dev/null)
        
        [[ -z "$iso_path" ]] && echo -e "${ROJO}Selección cancelada.${NC}" && exit 1
    else
        read "iso_path?Ruta de la ISO: "
        iso_path="${iso_path//\"/}"; iso_path="${iso_path//\'/}"; iso_path="${iso_path//\\ / }"
    fi

    [[ ! -f "$iso_path" ]] && echo -e "${ROJO}El archivo ISO no existe.${NC}" && exit 1
}

# --- PARSEO DE ARGUMENTOS ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --device) device="$2"; shift 2 ;;
        --file) iso_path="$2"; shift 2 ;;
        -h|--help) uso ;;
        *) echo "Parámetro desconocido: $1"; uso ;;
    esac
done

# --- LÓGICA PRINCIPAL ---
verificar_root
verificar_dependencias
seleccionar_iso
seleccionar_dispositivo

echo -e "${AMARILLO}==================================================${NC}"
echo -e "${AMARILLO}MODO HÍBRIDO: Limpieza profunda + Grabación ISO${NC}"
echo -e "${AMARILLO}ADVERTENCIA: Esto destruirá todos los datos en $device${NC}"
echo -e "${AMARILLO}==================================================${NC}"
read "confirmacion?¿Continuar? (s/N): "
[[ "$confirmacion" != "s" && "$confirmacion" != "S" ]] && exit 0

echo -e "\n${AZUL}[1/4] Desmontando y limpiando firmas...${NC}"
umount "${device}"* 2>/dev/null
wipefs -a "$device" &>/dev/null

echo -e "${AZUL}[2/4] Borrando tabla de particiones (Zerofill)...${NC}"
dd if=/dev/zero of="$device" bs=1M count=20 status=none conv=fsync

local size=$(stat -c %s "$iso_path")
echo -e "${AZUL}[3/4] Grabando ISO de forma segura...${NC}"

pv -s "$size" -pert < "$iso_path" | dd bs=4M of="$device" oflag=sync conv=notrunc status=none

if [[ $? -eq 0 ]]; then
    finalizar_proceso "$device"
else
    echo -e "\n${ROJO}¡Alerta! Error detectado en la escritura de bloques.${NC}"
    exit 1
fi
