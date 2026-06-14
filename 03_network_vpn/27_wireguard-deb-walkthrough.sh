#!/usr/bin/zsh


GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color



# https://www.youtube.com/watch?v=Gs6MFbL_8AA

# Update system
sudo apt update && sudo apt upgrade -y

# Install WireGuard
sudo apt install wireguard -y

# 1.2. Generar Claves del Servidor
# WireGuard usa pares de claves pública/privada.
# Muevete al directorio de configuración y genera la clave privada:
cd /etc/wireguard
# Establece permisos seguros lo mismo que chmod 600, pero ya se aplica a todo el directorio
umask 077

# Generate a private key and save: 
echo -e "${CYAN}Generate a private key and save: \n${NC}"
# En una sola línea podemos crear las dos claves
wg genkey | tee server_private.key | wg pubkey > server_public.key
# Nota: Guarda el contenido de server_private.key y server_public.key.
# 1.3. Crear el Archivo de Configuración del Servidor (wg0.conf)
# El nombre de la interfaz será wg0.

# Crea el archivo /etc/wireguard/wg0.conf:
echo -e "${CYAN}Crea el archivo /etc/wireguard/wg0.conf:\n${NC}"
sudo nano /etc/wireguard/wg0.conf

# /etc/wireguard/wg0.conf
function wg0_conf() {
[Interface]
# IP del servidor dentro del túnel (Gateway de la VPN)
Address = 10.200.0.1/24
# Puerto que escuchará WireGuard
ListenPort = 51820
# Clave privada del Servidor
PrivateKey = aECo/Wkmdg+6nk9DrtBKykbPuMmkyratD84E8s7wo0s=
# Reglas de Firewall (iptables) para permitir el tráfico y hacer NAT
# Reemplaza 'eth0' por el nombre real de tu interfaz de red si es distinto
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o enp0s3 -j
MASQUERADE
# [Peer] para el Cliente Remoto (Se agregará en el Paso 2.2)
# Por ahora, solo tenemos la sección [Interface].
}

wg0_conf



echo -e "${CYAN}Iniciar el Servicio WireGuard\n${NC}"
sudo wg-quick up wg0 # Inicia la interfaz temporalmente
# Verifica el estado:
wg show

echo -e "${CYAN}Habilita el servicio para que persista tras el reinicio:\n${NC}"
sudo systemctl enable wg-quick@wg0

echo -e "${CYAN}Habilitar IP Forwarding:\n${NC}"
sudo nano /etc/sysctl.conf
#Descomenta la lína:
net.ipv4.ip_forward=1
#Aplicamos los cambios
sudo sysctl -p
#reiniciar equipo
sudo reboot

# CLIENT WIREGUARD CONFIGURATION: 
echo -e "${CYAN}Generar Claves del Cliente\n${NC}"
cd /etc/wireguard
wg genkey | sudo tee client_usuario1_private.key
sudo cat client_usuario1_private.key | wg pubkey | sudo tee client_usuario1_public.key
#En una sola línea podemos crear las dos claves
wg genkey | tee client_usuario2_private.key | wg pubkey > client_usuario2_public.key

#2.2: Configurar el Servidor (Añadir el Peer del Cliente)
echo -e "${CYAN}Configurar el Servidor (Añadir el Peer del Cliente)\n${NC}"
#Vuelve a editar el archivo del servidor /etc/wireguard/wg0.conf y añade la siguiente sección 
# [Peer] usando la clave pública del cliente (client-user1_public.key):
# ... Contenido anterior [Interface]
# [Peer]
# Clave pública del cliente (client_usuario1_public.key)
PublicKey = $(cat client_usuario1_public.key)
# Direcciones que este cliente podrá usar en la VPN, y que el servidor enrutará
AllowedIPs = 10.200.0.2/32
# Después de modificar /etc/wireguard/wg0.conf, reinicia el servicio en la Pasarela para
# aplicar el nuevo peer:
#OPCIÓN 1
sudo wg-quick down wg0
sudo wg-quick up wg0

#OPCIÓN 2
systemctl restart wg-quick@wg0
wg show
# 2.3: Configuración del Cliente
# Crea el archivo de configuración del cliente, por ejemplo, client-user1.conf:
# client-user1.conf
[Interface]
# IP del cliente dentro del túnel VPN
Address = 10.200.0.2/32
# Clave privada del cliente
PrivateKey = [CLIENT_PRIVATE_KEY]
[Peer]
# Clave pública del servidor
PublicKey = [SERVER_PUBLIC_KEY]
# La IP pública o WAN de la Pasarela (ej. 192.168.1.100 o la que obtenga en enp0s3)
Endpoint = [IP_WAN]:51820
# Esto es CRUCIAL. Indica qué tráfico debe ir por el túnel:
# Con este AllowedIPs haremos que se navegue desde la red interna del servidor.
AllowedIPs = 0.0.0.0/1, 128.0.0.0/1
PersistentKeepalive = 20

# 2.4: Prueba Final de Conexión
# 1. Transfiere el archivo client-user1.conf al Cliente Remoto (VM 3).
# 2. Instala el cliente WireGuard en VM 3: sudo apt install wireguard -y (si es Linux).
# Conéctate:
sudo wg-quick up client-user1
# 3. Verificación Crucial: Haz ping a los recursos internos:
# ○ Ping a la ip del router
# ○ Ping al Servidor Interno
# ○ Si ambos pings son exitosos, la implementación de WireGuard es
correcta.

# 3. Script de Generación de Cliente WireGuard con QR
# A continuación, se muestra un ejemplo de un script de Bash que puedes ejecutar en tu
# Servidor WireGuard.
# Este script asume que estás usando la configuración del servidor en
# /etc/wireguard/wg0.conf y la subred 10.200.0.0/24 :

# 3.1 Instalar qrencode y zip.
sudo apt update
sudo apt install qrencode zip -y
sudo nano /usr/local/bin/cliente-wireguard.sh
# Dale permisos de ejecución (chmod +x):

# ZTE F6640 Port Forwarding:
# Go to the router's web interface (192.168.1.1)
# Go to the LAN > Security > Port Forwarding
# Add a new port forwarding rule:
# Name: WireGuard
# Protocol: UDP
# External Port: 51820
# Internal IP: 192.168.1.100
# Internal Port: 51820
# Save the changes.


#sudo chmod +x /usr/local/bin/cliente-wireguard.sh
# 3.2 Ejecución del Script

# Ejecuta el script con el nombre que desees para el cliente:

#sudo cliente-wireguard.sh user-movil
# Esto generará un archivo user-movil_client_config.zip en /tmp/ que contiene:
# user-movil.conf (El perfil de conexión para el cliente).
# user-movil_qr.png (El código QR para escanear en dispositivos móviles).
# Deberás mover este archivo ZIP fuera del servidor (por ejemplo, usando scp o
# montando una carpeta compartida) para entregárselo al cliente.