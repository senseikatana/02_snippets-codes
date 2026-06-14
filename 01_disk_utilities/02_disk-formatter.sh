#!/usr/bin/env zsh

# ==============================================================================
# SCRIPT: usb-format.sh
# DESCRIPCIÓN: Formatea unidades. Detecta inteligentemente si es interno/externo.
# ==============================================================================

ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
AZUL='\033[0;34m'
NC='\033[0m'

device=""
fs_type=""
label_name=""

uso() {
    echo -e "${AZUL}Uso:${NC} sudo $0 [--device /dev/sdx] [--fs fat32|exfat|ntfs|ext4|btrfs|xfs|f2fs] [--name NOMBRE]"
    exit 1
}

verificar_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${ROJO}Este script debe ejecutarse como root (sudo).${NC}"
        exit 1
    fi
}

verificar_dependencias() {
    for dep in parted eject lsblk wipefs mkfs.vfat mkfs.btrfs mkfs.xfs; do
        if ! command -v "$dep" &> /dev/null; then
            echo -e "${AMARILLO}[!] Nota: Falta la herramienta '$dep' en tu sistema.${NC}"
        fi
    done
}

finalizar_proceso() {
    local dev="$1"
    echo -e "\n${AZUL}Estado final del dispositivo:${NC}"
    # Muestra la tabla limpia con el FSTYPE incluido
    lsblk -o NAME,SIZE,TYPE,FSTYPE,LABEL,MOUNTPOINT "$dev"
    
    # Detección inteligente de tipo de disco
    local is_removable=$(lsblk -n -d -o RM "$dev" | tr -d ' ')
    local transport=$(lsblk -n -d -o TRAN "$dev" | tr -d ' ')

    echo -e "\n${AZUL}Sincronizando datos...${NC}"
    sync

    if [[ "$is_removable" == "1" || "$transport" == "usb" ]]; then
        echo -e "${AZUL}Expulsando dispositivo externo...${NC}"
        eject "$dev" 2>/dev/null
        echo -e "${VERDE}¡Listo! Ya puedes retirar el USB/Disco externo físicamente.${NC}"
    else
        echo -e "${VERDE}¡Listo! El disco interno '$dev' está formateado y preparado para usarse.${NC}"
    fi
    exit 0
}

progreso_formateo() {
    echo -ne "${VERDE}[####]${NC} $1\r"; sleep 0.3
    echo -ne "${VERDE}[####]${NC} $1 - ${VERDE}OK${NC}    \n"
}

wait_for_partition() {
    local partition="$1"
    local timeout=15
    local count=0
    
    echo -e "${AZUL}Esperando partición $partition...${NC}"
    while [[ ! -b "$partition" && $count -lt $timeout ]]; do
        sleep 1; ((count++))
        partprobe "$device" 2>/dev/null
    done
    
    if [[ ! -b "$partition" ]]; then
        echo -e "\n${ROJO}Error: La partición $partition no apareció.${NC}"; exit 1
    fi
}

seleccionar_dispositivo() {
    if [[ -n "$device" ]]; then return; fi
    echo -e "\n${AZUL}Dispositivos disponibles:${NC}"
    lsblk -d -o NAME,SIZE,MODEL,TRAN | grep -v "loop"
    echo ""
    read "device?Ingresa el dispositivo (ej: /dev/sdb): "
    [[ ! -b "$device" ]] && echo -e "${ROJO}Dispositivo inválido.${NC}" && exit 1
}

seleccionar_filesystem() {
    if [[ -n "$fs_type" ]]; then return; fi
    echo -e "\n${AZUL}Sistemas de archivos:${NC}"
    echo "1) fat32  (Universal, límite 4GB por archivo)"
    echo "2) exfat  (Universal, sin límites)"
    echo "3) ntfs   (Windows nativo)"
    echo "4) ext4   (Linux nativo estándar)"
    echo "5) btrfs  (Linux moderno, snapshots)"
    echo "6) xfs    (Linux robusto, discos grandes)"
    echo "7) f2fs   (Linux optimizado para Flash/SD)"
    echo ""
    read "fs_opt?Selecciona una opción (1-7): "
    case $fs_opt in
        1) fs_type="fat32" ;;
        2) fs_type="exfat" ;;
        3) fs_type="ntfs" ;;
        4) fs_type="ext4" ;;
        5) fs_type="btrfs" ;;
        6) fs_type="xfs" ;;
        7) fs_type="f2fs" ;;
        *) fs_type="fat32" ;;
    esac
}

# --- PARSEO DE ARGUMENTOS ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --device) device="$2"; shift 2 ;;
        --fs) fs_type="$2"; shift 2 ;;
        --name) label_name="$2"; shift 2 ;;
        -h|--help) uso ;;
        *) echo "Parámetro desconocido: $1"; uso ;;
    esac
done

# --- LÓGICA PRINCIPAL ---
verificar_root
verificar_dependencias
seleccionar_dispositivo
seleccionar_filesystem

if [[ -z "$label_name" ]]; then
    read "label_name?Nombre para la unidad (Enter para 'USB_DISK'): "
    label_name=${label_name:-"USB_DISK"}
fi

echo -e "${AMARILLO}ADVERTENCIA: Se eliminarán TODOS los datos en $device${NC}"
read "confirmacion?¿Estás seguro? (s/N): "
[[ "$confirmacion" != "s" && "$confirmacion" != "S" ]] && exit 0

echo -e "\n${AZUL}Desmontando y limpiando...${NC}"
umount "${device}"* 2>/dev/null
wipefs -a "$device" &>/dev/null
dd if=/dev/zero of="$device" bs=512 count=1 conv=notrunc status=none 2>/dev/null

# progreso_formateo "Creando tabla de particiones (MSDOS)"
# parted -s "$device" mklabel msdos &>/dev/null

progreso_formateo "Creando tabla de particiones (GPT)"
parted -s "$device" mklabel gpt &>/dev/null

progreso_formateo "Creando partición primaria"
parted -s "$device" mkpart primary 0% 100% &>/dev/null

partprobe "$device" 2>/dev/null; sleep 0.5
particion="${device}1"
[[ "$device" == *"nvme"* || "$device" == *"mmcblk"* ]] && particion="${device}p1"
wait_for_partition "$particion"

echo -e "\n${AZUL}Formateando a $fs_type con nombre '$label_name'...${NC}"

if [[ "$fs_type" == "fat32" && ${#label_name} -gt 11 ]]; then
    label_name=${label_name:0:11}
elif [[ "$fs_type" == "xfs" && ${#label_name} -gt 12 ]]; then
    label_name=${label_name:0:12}
fi

case "$fs_type" in
    fat32) mkfs.vfat -F 32 -n "$label_name" "$particion" ;;
    exfat) mkfs.exfat -n "$label_name" "$particion" ;;
    ntfs)  mkfs.ntfs -f -L "$label_name" "$particion" ;;
    ext4)  mkfs.ext4 -F -L "$label_name" "$particion" ;;
    btrfs) mkfs.btrfs -f -L "$label_name" "$particion" ;;
    xfs)   mkfs.xfs -f -L "$label_name" "$particion" ;;
    f2fs)  mkfs.f2fs -f -l "$label_name" "$particion" ;;
esac

if [[ $? -eq 0 ]]; then
    echo -e "\n${VERDE}¡Formateo completado con éxito!${NC}"
else
    echo -e "\n${ROJO}Ocurrió un error (¿Tienes instaladas las herramientas mkfs.$fs_type?).${NC}"
fi

finalizar_proceso "$device"
