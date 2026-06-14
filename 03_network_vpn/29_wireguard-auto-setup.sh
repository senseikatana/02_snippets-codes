#!/bin/zsh

# --- 1. LIMPIEZA Y PREPARACIÓN ---
echo "🧹 Limpiando configuraciones anteriores..."
sudo systemctl stop wg-quick@wg0 2>/dev/null
sudo rm -rf /etc/wireguard/*

# --- 2. DETECCIÓN AUTOMÁTICA ---
# Detectamos la interfaz de red (ej: enp7s0)
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n 1)
echo "🌐 Interfaz de red detectada: $INTERFACE"

# Detectamos tu IP Pública automáticamente
PUBLIC_IP=$(curl -s -4 icanhazip.com)
echo "🌍 Tu IP Pública detectada es: $PUBLIC_IP"
echo "-------------------------------------------"
echo "¿Quieres usar esta IP? (Pulsa ENTER para Sí)"
echo "O escribe tu dominio DuckDNS (ej: midominio.duckdns.org) y pulsa ENTER:"
read ENDPOINT_INPUT

if [ -z "$ENDPOINT_INPUT" ]; then
    SERVER_ENDPOINT="${PUBLIC_IP}:51820"
else
    SERVER_ENDPOINT="${ENDPOINT_INPUT}:51820"
fi

echo "🔗 Configurando Endpoint: $SERVER_ENDPOINT"

# --- 3. INSTALACIÓN SERVIDOR ---
echo "🔧 Instalando y configurando servidor..."
sudo pacman -S --needed wireguard-tools iptables qrencode zip --noconfirm

cd /etc/wireguard
umask 077
sudo wg genkey | tee server_private.key | wg pubkey > server_public.key
chmod 600 server_private.key

SERVER_PRIVATE_KEY=$(sudo cat server_private.key)
SERVER_PUBLIC_KEY=$(sudo cat server_public.key)

# Crear configuración del servidor
sudo tee /etc/wireguard/wg0.conf > /dev/null <<EOF
[Interface]
Address = 10.200.0.1/24
ListenPort = 51820
PrivateKey = ${SERVER_PRIVATE_KEY}
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ${INTERFACE} -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ${INTERFACE} -j MASQUERADE
EOF

# --- 4. FIREWALL (UFW) ---
# Verificamos si UFW está activo y abrimos puerto
if sudo ufw status | grep -q "Status: active"; then
    echo "🔒 UFW activo detectado. Abriendo puerto 51820 UDP..."
    sudo ufw allow 51820/udp
    sudo ufw reload
else
    echo "ℹ️ UFW no está activo, no es necesario abrir puerto local."
fi

# Activar IP Forwarding
echo "🌐 Activando IP Forwarding..."
sudo sed -i '/net.ipv4.ip_forward/s/^#//g' /etc/sysctl.d/99-sysctl.conf
grep -q "net.ipv4.ip_forward=1" /etc/sysctl.d/99-sysctl.conf || echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf
sudo sysctl -p /etc/sysctl.d/99-sysctl.conf > /dev/null

# Iniciar servicio
sudo systemctl enable --now wg-quick@wg0

# --- 5. CREAR CLIENTE MÓVIL ---
echo "📱 Generando configuración para el móvil..."
CLIENT_NAME="movil"
CLIENT_IP="10.200.0.2"
CLIENT_PRIVATE_KEY=$(wg genkey)
CLIENT_PUBLIC_KEY=$(echo "${CLIENT_PRIVATE_KEY}" | wg pubkey)

# Añadir peer al servidor
echo -e "\n[Peer]\nPublicKey = ${CLIENT_PUBLIC_KEY}\n# ${CLIENT_NAME}\nAllowedIPs = ${CLIENT_IP}/32" | sudo tee -a /etc/wireguard/wg0.conf > /dev/null
sudo wg syncconf wg0 <(sudo wg-quick strip wg0)

# Crear archivo .conf
CONF_FILE="/tmp/${CLIENT_NAME}.conf"
cat <<EOF > $CONF_FILE
[Interface]
PrivateKey = ${CLIENT_PRIVATE_KEY}
Address = ${CLIENT_IP}/32
DNS = 1.1.1.1, 94.140.14.14
MTU = 1280

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
Endpoint = ${SERVER_ENDPOINT}
AllowedIPs = 0.0.0.0/1, 128.0.0.0/1
PersistentKeepalive = 20
EOF

echo "✅ ¡CONFIGURACIÓN COMPLETA!"
echo "-------------------------------------------"
echo "Escanea este código QR con la app WireGuard:"
echo ""
qrencode -t ansiutf8 < $CONF_FILE
echo ""
echo "Archivo de respaldo en: $CONF_FILE"
