#!/usr/bin/env zsh
# ==============================================================================
# INSTALLATION SCRIPT FOR PASSWORD GENERATOR SYSTEMD SERVICE
# Installs password-generator to /usr/local/bin and sets up the systemd service.
# ==============================================================================

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ Error: This script must be run with sudo/root privileges.${NC}"
   exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_SOURCE="${SCRIPT_DIR}/22_pgen.py"
SERVICE_SOURCE="${SCRIPT_DIR}/pgen.service"

BIN_DEST="/usr/local/bin/pgen"
SERVICE_DEST="/etc/systemd/system/pgen.service"

echo -e "${CYAN}=== INSTALLING PASSWORD GENERATOR MICROSERVICE ===${NC}"

# 1. Copy CLI/Daemon script
echo -e "${GREEN}[1/4] Installing executable script to ${BIN_DEST}...${NC}"
cp "$BIN_SOURCE" "$BIN_DEST"
chmod +x "$BIN_DEST"

# 2. Copy systemd service file
echo -e "${GREEN}[2/4] Installing systemd service unit...${NC}"
cp "$SERVICE_SOURCE" "$SERVICE_DEST"

# 3. Reload systemd daemon
echo -e "${GREEN}[3/4] Reloading systemd...${NC}"
systemctl daemon-reload

# 4. Enable and start service
echo -e "${GREEN}[4/4] Enabling and starting password-generator service...${NC}"
systemctl enable --now pgen

# Check status
if systemctl is-active --quiet pgen; then
    echo -e "\n${GREEN}✔ Installation completed successfully!${NC}"
    echo -e "The password generator service is running on ${CYAN}http://127.0.0.1:7777${NC}"
    echo -e "\n${YELLOW}💡 Try querying it locally with curl:${NC}"
    echo -e "  - Default secure password:      ${CYAN}curl http://localhost:7777${NC}"
    echo -e "  - Matrícula style (2 plates):   ${CYAN}curl \"http://localhost:7777?type=matricula&qty=2\"${NC}"
    echo -e "  - Pin / Numeric (8 digits):    ${CYAN}curl \"http://localhost:7777?type=numeric&length=8\"${NC}"
    echo -e "  - Memorable / XKCD (4 words):   ${CYAN}curl \"http://localhost:7777?type=memorable\"${NC}"
    echo -e "  - JSON response (count=3):     ${CYAN}curl \"http://localhost:7777?type=secure&count=3&format=json\"${NC}"
    echo -e "\n${YELLOW}💡 You can also use the CLI directly anywhere:${NC}"
    echo -e "  - ${CYAN}pgen --help${NC}"
    echo -e "  - ${CYAN}pgen -t memorable -q 3${NC}"
else
    echo -e "\n${RED}❌ Error: Service failed to start. Check logs with 'journalctl -u password-generator'${NC}"
    exit 1
fi
