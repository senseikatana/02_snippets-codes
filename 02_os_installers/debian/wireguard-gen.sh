#!/usr/bin/env zsh
set -euo pipefail

# --- SERVER NETWORK CONFIGURATION ---
SERVER_PUBLIC_KEY=$(sudo wg show wg0 public-key 2>/dev/null || echo "")
# Change this to your server's public IP or domain
SERVER_PUBLIC_IP="192.168.1.100"
SERVER_ENDPOINT="${SERVER_PUBLIC_IP}:51820"
VPN_SUBNET="10.200.0"
SERVER_VPN_IP="${VPN_SUBNET}.1"
WG_CONF="/etc/wireguard/wg0.conf"

# --- FUNCTION TO INSTALL DEPENDENCIES (Debian/Ubuntu) ---
install_dependencies() {
    local missing_pkgs=()
    
    command -v wg >/dev/null 2>&1 || missing_pkgs+=("wireguard-tools")
    command -v qrencode >/dev/null 2>&1 || missing_pkgs+=("qrencode")
    command -v zip >/dev/null 2>&1 || missing_pkgs+=("zip")
    
    if [ ${#missing_pkgs[@]} -gt 0 ]; then
        echo "Installing missing dependencies: ${missing_pkgs[*]}"
        sudo apt update
        sudo apt install -y "${missing_pkgs[@]}"
    fi
}

# --- INITIAL VALIDATIONS ---
if [ -z "$SERVER_PUBLIC_KEY" ]; then
    echo "Error: Could not get wg0 public key. Is WireGuard configured?"
    exit 1
fi

CLIENT_NAME=${1:-}
if [ -z "$CLIENT_NAME" ]; then
    echo "Usage: $0 <client_name>"
    exit 1
fi

# Validate that the name only contains safe characters
if [[ ! "$CLIENT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: Client name can only contain letters, numbers, hyphens and underscores"
    exit 1
fi

# Install dependencies
install_dependencies

# --- CALCULATE NEXT AVAILABLE IP ---
USED_LAST_OCTETS=$(grep -E '^[[:space:]]*AllowedIPs[[:space:]]*=' "$WG_CONF" 2>/dev/null \
    | sed -n 's/^[[:space:]]*AllowedIPs[[:space:]]*=[[:space:]]*[0-9]\+\.[0-9]\+\.[0-9]\+\.//p' \
    | sed 's#/.*##' \
    | grep -E '^[0-9]+$' || true)

if [ -z "$USED_LAST_OCTETS" ]; then
    NEXT_IP=2
else
    LAST_IP=$(echo "$USED_LAST_OCTETS" | sort -n | tail -1)
    NEXT_IP=$((LAST_IP + 1))
    [ "$NEXT_IP" -eq 1 ] && NEXT_IP=2
fi

if [ "$NEXT_IP" -ge 255 ]; then
    echo "Error: No available IPs in ${VPN_SUBNET}.0/24"
    exit 1
fi

CLIENT_IP="${VPN_SUBNET}.${NEXT_IP}"

if grep -q "AllowedIPs = ${CLIENT_IP}/32" "$WG_CONF" 2>/dev/null; then
    echo "Error: IP ${CLIENT_IP}/32 already assigned"
    exit 1
fi

echo "Generating configuration for: $CLIENT_NAME (IP: ${CLIENT_IP}/32)"

# --- GENERATE KEYS ---
CLIENT_PRIVATE_KEY=$(wg genkey)
CLIENT_PUBLIC_KEY=$(echo "$CLIENT_PRIVATE_KEY" | wg pubkey)

# --- CREATE TEMPORARY DIRECTORY ---
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# --- CREATE CLIENT CONFIGURATION ---
CLIENT_CONF="${TEMP_DIR}/${CLIENT_NAME}.conf"
cat > "$CLIENT_CONF" << EOF
[Interface]
PrivateKey = ${CLIENT_PRIVATE_KEY}
Address = ${CLIENT_IP}/32
DNS = 1.1.1.1, 9.9.9.9

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
AllowedIPs = 0.0.0.0/0
Endpoint = ${SERVER_ENDPOINT}
PersistentKeepalive = 20
EOF

# --- ADD PEER TO SERVER ---
echo -e "\n[Peer]\nPublicKey = ${CLIENT_PUBLIC_KEY}\nAllowedIPs = ${CLIENT_IP}/32" \
    | sudo tee -a "$WG_CONF" > /dev/null

# --- SYNC CONFIGURATION (without full restart) ---
sudo wg addconf wg0 <(echo "[Peer]
PublicKey = ${CLIENT_PUBLIC_KEY}
AllowedIPs = ${CLIENT_IP}/32") 2>/dev/null || {
    echo "Restarting WireGuard to apply changes..."
    sudo systemctl restart wg-quick@wg0
}

echo "✓ Peer added to server"

# --- GENERATE QR CODE ---
QR_FILE="${TEMP_DIR}/${CLIENT_NAME}_qr.png"
qrencode -o "$QR_FILE" < "$CLIENT_CONF"
echo "✓ QR code generated"

# --- CREATE ZIP FILE ---
OUTPUT_DIR="${HOME}/wireguard_clients"
mkdir -p "$OUTPUT_DIR"
ZIP_FILE="${OUTPUT_DIR}/${CLIENT_NAME}_$(date +%Y%m%d).zip"
zip -j "$ZIP_FILE" "$CLIENT_CONF" "$QR_FILE" > /dev/null

# --- SHOW SUMMARY ---
echo -e "\n✅ CLIENT CONFIGURED SUCCESSFULLY"
echo "═══════════════════════════════════════"
echo "📁 ZIP file: $ZIP_FILE"
echo "📱 QR: ${QR_FILE}"
echo "🌐 Assigned IP: ${CLIENT_IP}/32"
echo "🔑 Public key: ${CLIENT_PUBLIC_KEY:0:20}..."
echo "═══════════════════════════════════════"
