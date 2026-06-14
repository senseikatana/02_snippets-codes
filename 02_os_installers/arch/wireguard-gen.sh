#!/usr/bin/env zsh

set -euo pipefail

# --- COLORS FOR OUTPUT (Optional) ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- HELP FUNCTION ---
show_help() {
    cat << EOF
Usage: $0 <client_name> [--dry-run]

Generates a WireGuard client configuration and adds it to the server.
Supports native (Host) and container (Podman/Docker) installations.

Arguments:
  client_name       Name for the client (only letters, numbers, - and _)
  --dry-run         Simulates execution without modifying the server

EOF
    exit 0
}

# --- ENVIRONMENT DETECTION (Native vs Container) ---
detect_environment() {
    if systemctl is-active --quiet wg-quick@wg0 2>/dev/null; then
        ENV_TYPE="host"
        WG_CMD="sudo wg"
        CONF_PATH="/etc/wireguard/wg0.conf"
    elif sudo podman ps --format "{{.Names}}" | grep -q "wireguard\|wg"; then
        ENV_TYPE="podman"
        CONTAINER_NAME=$(sudo podman ps --format "{{.Names}}" | grep -E "wireguard|wg" | head -1)
        WG_CMD="sudo podman exec $CONTAINER_NAME wg"
        CONF_PATH="/etc/wireguard/wg0.conf" # Assume volume is mapped here
        echo -e "${YELLOW}ℹ Environment detected: Podman (Container: $CONTAINER_NAME)${NC}"
    elif sudo docker ps --format "{{.Names}}" | grep -q "wireguard\|wg"; then
        ENV_TYPE="docker"
        CONTAINER_NAME=$(sudo docker ps --format "{{.Names}}" | grep -E "wireguard|wg" | head -1)
        WG_CMD="sudo docker exec $CONTAINER_NAME wg"
        CONF_PATH="/etc/wireguard/wg0.conf" # Assume volume is mapped here
        echo -e "${YELLOW}ℹ Environment detected: Docker (Container: $CONTAINER_NAME)${NC}"
    else
        echo -e "${RED}❌ Error: No WireGuard instance found running on host or in containers.${NC}"
        exit 1
    fi
}

# --- VALIDATE DEPENDENCIES ---
check_deps() {
    local missing=()
    command -v wg >/dev/null 2>&1 || missing+=("wireguard-tools")
    command -v qrencode >/dev/null 2>&1 || missing+=("qrencode")
    command -v zip >/dev/null 2>&1 || missing+=("zip")
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}❌ Missing dependencies: ${missing[*]}${NC}"
        echo "Install with: sudo apt install ${missing[*]}   (or use your package manager)"
        exit 1
    fi
}

# --- GET SERVER CONFIG FROM THE ACTUAL FILE ---
parse_server_config() {
    # 1. Get Server Public Key
    SERVER_PUBLIC_KEY=$($WG_CMD show wg0 public-key 2>/dev/null)
    if [ -z "$SERVER_PUBLIC_KEY" ]; then
        echo -e "${RED}❌ Error: Could not get public key for wg0.${NC}"
        exit 1
    fi

    # 2. Get Endpoint (Public IP:Port) from the [Interface] section of wg0.conf
    #    Look for "ListenPort" line for the port and use a real public IP (not local)
    LISTEN_PORT=$(grep -E "^ListenPort" "$CONF_PATH" | awk '{print $3}' | head -1)
    LISTEN_PORT=${LISTEN_PORT:-51820}
    
    # Try to get the actual public IP of the server (more reliable than hardcoding)
    SERVER_PUBLIC_IP=$(curl -s --max-time 5 ifconfig.me || curl -s --max-time 5 icanhazip.com || echo "")
    if [ -z "$SERVER_PUBLIC_IP" ]; then
        echo -e "${YELLOW}⚠ Could not detect public IP automatically.${NC}"
        read -p "Enter the Public IP or Domain of the server: " SERVER_PUBLIC_IP
    fi
    
    SERVER_ENDPOINT="${SERVER_PUBLIC_IP}:${LISTEN_PORT}"
    echo -e "${GREEN}✓ Endpoint detected: ${SERVER_ENDPOINT}${NC}"

    # 3. Get VPN Subnet (e.g. 10.200.0) from the server's Address
    SERVER_VPN_IP=$($WG_CMD show wg0 | grep -E "interface: wg0" -A5 | grep "inet " | awk '{print $2}' | cut -d'/' -f1)
    VPN_SUBNET=$(echo "$SERVER_VPN_IP" | sed 's/\.[0-9]*$//')
    
    if [ -z "$VPN_SUBNET" ]; then
        echo -e "${RED}❌ Error: Could not determine VPN subnet.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ VPN Subnet: ${VPN_SUBNET}.0/24${NC}"
}

# --- CALCULATE NEXT AVAILABLE IP ---
calculate_next_ip() {
    # Get already assigned IPs (from the config file for accuracy)
    USED_LAST_OCTETS=$(grep -E '^AllowedIPs' "$CONF_PATH" 2>/dev/null | \
        sed -n 's/.*AllowedIPs.*=.*[0-9]\+\.[0-9]\+\.[0-9]\+\.\([0-9]\+\).*/\1/p' | \
        sort -n | uniq)
    
    if [ -z "$USED_LAST_OCTETS" ]; then
        NEXT_IP=2
    else
        LAST_IP=$(echo "$USED_LAST_OCTETS" | tail -1)
        NEXT_IP=$((LAST_IP + 1))
    fi
    
    # Skip server IP (.1)
    if [ "$NEXT_IP" -eq 1 ]; then NEXT_IP=2; fi
    
    if [ "$NEXT_IP" -ge 255 ]; then
        echo -e "${RED}❌ Error: Subnet full. No IPs available.${NC}"
        exit 1
    fi
    
    CLIENT_IP="${VPN_SUBNET}.${NEXT_IP}"
    
    # Check for exact duplicate
    if grep -q "AllowedIPs = ${CLIENT_IP}/32" "$CONF_PATH"; then
        echo -e "${RED}❌ Error: IP ${CLIENT_IP} already exists in configuration.${NC}"
        exit 1
    fi
}

# --- MAIN PROCESS ---
main() {
    # Parse arguments
    DRY_RUN=false
    CLIENT_NAME=""

    for arg in "$@"; do
        case "$arg" in
            --dry-run) DRY_RUN=true ;;
            --help|-h) show_help ;;
            *)
                if [ -z "$CLIENT_NAME" ]; then
                    CLIENT_NAME="$arg"
                else
                    echo -e "${RED}Error: Unknown argument: $arg${NC}"
                    exit 1
                fi
                ;;
        esac
    done

    if [ -z "$CLIENT_NAME" ] || [[ ! "$CLIENT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo -e "${RED}Error: Invalid client name.${NC}"
        show_help
    fi

    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}⚠ DRY-RUN MODE: No changes will be applied to the server.${NC}"
    fi

    # Initial setup
    detect_environment
    check_deps
    parse_server_config
    calculate_next_ip
    
    echo -e "${GREEN}→ Generating client: ${CLIENT_NAME} (${CLIENT_IP})${NC}"

    # Generate keys
    CLIENT_PRIVATE_KEY=$(wg genkey)
    CLIENT_PUBLIC_KEY=$(echo "$CLIENT_PRIVATE_KEY" | wg pubkey)

    # Create temporary files
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT
    
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

    QR_FILE="${TEMP_DIR}/${CLIENT_NAME}.png"
    qrencode -o "$QR_FILE" < "$CLIENT_CONF"

    if [ "$DRY_RUN" = false ]; then
        # --- APPLY CHANGES (depending on environment) ---
        PEER_ENTRY="[Peer]\nPublicKey = ${CLIENT_PUBLIC_KEY}\nAllowedIPs = ${CLIENT_IP}/32"
        
        # 1. Write to persistent configuration file
        echo -e "\n$PEER_ENTRY" | sudo tee -a "$CONF_PATH" > /dev/null
        
        # 2. Add live to the active interface (Native or Container)
        if [ "$ENV_TYPE" = "host" ]; then
            sudo wg addconf wg0 <(echo -e "$PEER_ENTRY")
        else
            # Podman/Docker: Execute inside the container
            sudo $WG_CMD addconf wg0 <(echo -e "$PEER_ENTRY")
            echo -e "${YELLOW}⚠ Remember: If you recreate the container, ensure the volume at ${CONF_PATH} persists.${NC}"
        fi
        
        echo -e "${GREEN}✓ Peer successfully added to active server.${NC}"
    fi

    # Package result
    OUTPUT_DIR="./wireguard_clients"
    mkdir -p "$OUTPUT_DIR"
    ZIP_FILE="${OUTPUT_DIR}/${CLIENT_NAME}_$(date +%Y%m%d).zip"
    zip -j "$ZIP_FILE" "$CLIENT_CONF" "$QR_FILE" > /dev/null

    # Final summary
    echo -e "\n${GREEN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ CLIENT CONFIGURED${NC}"
    echo -e "📁 ZIP: ${ZIP_FILE}"
    echo -e "🌐 IP:  ${CLIENT_IP}"
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}⚠ Dry-Run Mode: Server was not modified.${NC}"
    fi
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
}

# Run main function with all arguments
main "$@"
