#!/usr/bin/env zsh
# ==============================================================================
# INSTALLATION SCRIPT FOR PASSWORD GENERATOR SYSTEMD SERVICE (ZSH VERSION)
# Compiles the TypeScript password generator, installs it to /usr/local/bin,
# and configures it to run as a background systemd microservice.
# ==============================================================================

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running as root/sudo
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ Error: This script must be run with sudo/root privileges.${NC}"
   exit 1
fi

# Detect absolute paths of source files
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TS_SOURCE="${SCRIPT_DIR}/pgen.ts"
SERVICE_SOURCE="${SCRIPT_DIR}/pgen.service"

BIN_DEST="/usr/local/bin/pgen"
SERVICE_DEST="/etc/systemd/system/pgen.service"

echo -e "${CYAN}=== INSTALLING PASSWORD GENERATOR MICROSERVICE (TS/JS VERSION) ===${NC}"

# Check for Node.js and npm/npx
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Error: Node.js is not installed. Please install Node.js first.${NC}"
    exit 1
fi

if ! command -v npx &> /dev/null; then
    echo -e "${RED}❌ Error: npx/npm is not installed. Please install npm first.${NC}"
    exit 1
fi

# 1. Compile TypeScript to executable JavaScript
echo -e "${GREEN}[1/4] Compiling TypeScript source (${TS_SOURCE}) to JavaScript...${NC}"
local temp_js="/tmp/pgen.js"

# Compile using npx esbuild
npx -y esbuild "$TS_SOURCE" --bundle --platform=node --outfile="$temp_js"

if [[ ! -f "$temp_js" ]]; then
    echo -e "${RED}❌ Error: TypeScript compilation failed.${NC}"
    exit 1
fi

# Write compiled JS with Node shebang to the destination
echo -e "${GREEN}[2/4] Installing executable Node script to ${BIN_DEST}...${NC}"
echo "#!/usr/bin/env node" > "$BIN_DEST"
cat "$temp_js" >> "$BIN_DEST"
chmod +x "$BIN_DEST"

# Clean up temp file
rm -f "$temp_js"

# 2. Copy systemd service file
echo -e "${GREEN}[3/4] Installing systemd service unit to ${SERVICE_DEST}...${NC}"
cp "$SERVICE_SOURCE" "$SERVICE_DEST"

# 3. Reload systemd daemon
echo -e "${GREEN}[4/4] Reloading systemd and starting service...${NC}"
systemctl daemon-reload

# 4. Enable and start service
systemctl enable --now pgen

# Verify if service started successfully
if systemctl is-active --quiet pgen; then
    echo -e "\n${GREEN}✔ Installation completed successfully!${NC}"
    echo -e "The password generator service is running on ${CYAN}http://127.0.0.1:7777${NC}"
    echo -e "\n${YELLOW}💡 Try querying the HTTP daemon:${NC}"
    echo -e "  - Default secure password:      ${CYAN}curl http://localhost:7777${NC}"
    echo -e "  - Matrícula style (2 plates):   ${CYAN}curl \"http://localhost:7777?type=matricula&qty=2\"${NC}"
    echo -e "  - Pin / Numeric (8 digits):    ${CYAN}curl \"http://localhost:7777?type=numeric&length=8\"${NC}"
    echo -e "  - Memorable / XKCD (4 words):   ${CYAN}curl \"http://localhost:7777?type=memorable\"${NC}"
    echo -e "  - JSON response (count=3):     ${CYAN}curl \"http://localhost:7777?type=secure&count=3&format=json\"${NC}"
    echo -e "\n${YELLOW}💡 You can also use the binary CLI anywhere:${NC}"
    echo -e "  - ${CYAN}pgen --help${NC}"
    echo -e "  - ${CYAN}pgen -t memorable -q 3${NC}"
else
    echo -e "\n${RED}❌ Error: Service failed to start. Check logs with 'journalctl -u pgen'${NC}"
    exit 1
fi
