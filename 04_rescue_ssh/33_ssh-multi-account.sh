#!/usr/bin/env zsh

# ==============================================================================
# SCRIPT DE CONFIGURACIÓN SSH PARA GITHUB Y GITLAB (VERSIÓN MEJORADA)
# ==============================================================================
# Antes de ejecutar, edita las variables de abajo con tus correos reales.
# Ejecución: chmod +x ssh_setup.sh && ./ssh_setup.sh
# ==============================================================================

# --- 1. CONFIGURACIÓN DE VARIABLES (EDITA AQUÍ TUS CORREOS) ---
EMAIL_GITHUB="tu_email_github@gmail.com"
EMAIL_GITLAB="tu_email_gitlab@empresa.com"
EMAIL_PERSONAL=""  # Opcional: déjalo vacío si no quieres clave personal
GITLAB_SELF_HOSTED=""  # Opcional: ej. "gitlab.mi-empresa.com"

# Rutas de las claves
SSH_DIR="$HOME/.ssh"
GITHUB_DIR="$SSH_DIR/github"
GITLAB_DIR="$SSH_DIR/gitlab"
KEY_GITHUB="$GITHUB_DIR/id_ed25519"
KEY_GITLAB="$GITLAB_DIR/id_ed25519"

# Colores para output más bonito
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- 2. VALIDACIÓN INICIAL ---
echo "${BLUE}🔐 SCRIPT DE CONFIGURACIÓN SSH${NC}"
echo "========================================"

# Validar correos electrónicos
if [[ "$EMAIL_GITHUB" == "tu_email_github@gmail.com" ]] || [[ "$EMAIL_GITLAB" == "tu_email_gitlab@empresa.com" ]]; then
    echo "${RED}❌ ERROR: Debes editar las variables EMAIL_GITHUB y EMAIL_GITLAB con tus correos reales.${NC}"
    echo "   Edita el script y modifica las líneas 12-13 antes de ejecutar."
    exit 1
fi

# --- 3. PREPARACIÓN DE CARPETAS ---
echo ""
echo "${BLUE}📁 Preparando estructura de carpetas...${NC}"

# Crear carpeta raíz .ssh si no existe
if [ ! -d "$SSH_DIR" ]; then
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    echo "   ${GREEN}✅${NC} Carpeta $SSH_DIR creada"
fi

# Crear subcarpetas
mkdir -p "$GITHUB_DIR"
mkdir -p "$GITLAB_DIR"
echo "   ${GREEN}✅${NC} Carpetas github/ y gitlab/ creadas"

# --- 4. BACKUP DEL CONFIG EXISTENTE ---
if [ -f "$SSH_DIR/config" ]; then
    BACKUP_FILE="$SSH_DIR/config.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$SSH_DIR/config" "$BACKUP_FILE"
    echo "   ${YELLOW}ℹ️${NC}  Backup del config anterior guardado en $BACKUP_FILE"
fi

# --- 5. GENERACIÓN DE CLAVES SSH ---
echo ""
echo "${BLUE}🔑 Generando claves SSH (Ed25519)...${NC}"

# Generar clave GitHub
if [ ! -f "$KEY_GITHUB" ]; then
    ssh-keygen -t ed25519 -C "$EMAIL_GITHUB" -f "$KEY_GITHUB" -N ""
    echo "   ${GREEN}✅${NC} Clave GitHub creada para $EMAIL_GITHUB"
else
    echo "   ${YELLOW}⚠️${NC}  Clave GitHub ya existe en $KEY_GITHUB. Se conservará la actual."
fi

# Generar clave GitLab
if [ ! -f "$KEY_GITLAB" ]; then
    ssh-keygen -t ed25519 -C "$EMAIL_GITLAB" -f "$KEY_GITLAB" -N ""
    echo "   ${GREEN}✅${NC} Clave GitLab creada para $EMAIL_GITLAB"
else
    echo "   ${YELLOW}⚠️${NC}  Clave GitLab ya existe en $KEY_GITLAB. Se conservará la actual."
fi

# Generar clave Personal (opcional)
if [[ -n "$EMAIL_PERSONAL" ]] && [[ "$EMAIL_PERSONAL" != "tu_email_personal@gmail.com" ]]; then
    PERSONAL_DIR="$SSH_DIR/personal"
    KEY_PERSONAL="$PERSONAL_DIR/id_ed25519"
    mkdir -p "$PERSONAL_DIR"
    
    if [ ! -f "$KEY_PERSONAL" ]; then
        ssh-keygen -t ed25519 -C "$EMAIL_PERSONAL" -f "$KEY_PERSONAL" -N ""
        echo "   ${GREEN}✅${NC} Clave Personal creada para $EMAIL_PERSONAL"
    else
        echo "   ${YELLOW}⚠️${NC}  Clave Personal ya existe en $KEY_PERSONAL. Se conservará la actual."
    fi
    PERSONAL_CONFIG=true
fi

# --- 6. CONFIGURACIÓN DEL ARCHIVO `config` ---
echo ""
echo "${BLUE}📝 Configurando archivo ~/.ssh/config...${NC}"

# Creamos el archivo config
cat << EOF > "$SSH_DIR/config"
# ==============================================================================
# SSH CONFIGURATION FILE
# Generado automáticamente: $(date)
# ==============================================================================

# --- GitHub Configuration ---
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github/id_ed25519
    IdentitiesOnly yes

# --- GitLab Configuration ---
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/gitlab/id_ed25519
    IdentitiesOnly yes

EOF

# Añadir configuración de GitLab self-hosted si existe
if [[ -n "$GITLAB_SELF_HOSTED" ]]; then
    cat << EOF >> "$SSH_DIR/config"
# --- GitLab Self-Hosted Configuration ---
Host $GITLAB_SELF_HOSTED
    HostName $GITLAB_SELF_HOSTED
    User git
    IdentityFile ~/.ssh/gitlab/id_ed25519
    IdentitiesOnly yes

EOF
fi

# Añadir configuración personal si existe
if [[ "$PERSONAL_CONFIG" == true ]]; then
    cat << EOF >> "$SSH_DIR/config"
# --- Personal GitHub Configuration ---
Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/personal/id_ed25519
    IdentitiesOnly yes

EOF
fi

# Permisos seguros para el config
chmod 600 "$SSH_DIR/config"
echo "   ${GREEN}✅${NC} Archivo config creado con permisos seguros"

# --- 7. INICIAR AGENTE Y AÑADIR CLAVES ---
echo ""
echo "${BLUE}🚀 Iniciando SSH Agent y añadiendo claves...${NC}"

# Iniciar agente
eval "$(ssh-agent -s)" > /dev/null 2>&1

# Añadir claves al agente
ssh-add "$KEY_GITHUB" 2>/dev/null && echo "   ${GREEN}✅${NC} Clave GitHub añadida" || echo "   ${YELLOW}⚠️${NC}  No se pudo añadir clave GitHub"
ssh-add "$KEY_GITLAB" 2>/dev/null && echo "   ${GREEN}✅${NC} Clave GitLab añadida" || echo "   ${YELLOW}⚠️${NC}  No se pudo añadir clave GitLab"

if [[ "$PERSONAL_CONFIG" == true ]]; then
    ssh-add "$KEY_PERSONAL" 2>/dev/null && echo "   ${GREEN}✅${NC} Clave Personal añadida" || echo "   ${YELLOW}⚠️${NC}  No se pudo añadir clave Personal"
fi

# --- 8. CONFIGURACIÓN PERSISTENTE DEL SSH AGENT ---
if ! grep -q "SSH_AUTH_SOCK" ~/.zshrc 2>/dev/null; then
    cat << 'EOF' >> ~/.zshrc

# ==============================================================================
# SSH Agent - Configuración automática (añadida por ssh_setup.sh)
# ==============================================================================
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent > ~/.ssh/ssh-agent.env
fi
if [[ ! "$SSH_AUTH_SOCK" ]]; then
    source ~/.ssh/ssh-agent.env > /dev/null
    # Cargar automáticamente todas las claves SSH
    find ~/.ssh -name "id_ed25519" -type f -exec ssh-add {} \; 2>/dev/null
fi
EOF
    echo "   ${GREEN}✅${NC} Configuración persistente del SSH Agent añadida a ~/.zshrc"
fi

# --- 9. MOSTRAR RESULTADOS ---
echo ""
echo "${GREEN}========================================================${NC}"
echo "${GREEN}✨ ¡CONFIGURACIÓN COMPLETADA!${NC}"
echo "${GREEN}========================================================${NC}"
echo ""

echo "${YELLOW}📋 CLAVES PÚBLICAS PARA COPIAR:${NC}"
echo ""

echo "${BLUE}👉 GITHUB${NC} (Copia esto y pégalo en Settings -> SSH and GPG keys):"
echo "--------------------------------------------------------"
cat "${KEY_GITHUB}.pub"
echo "--------------------------------------------------------"
echo ""

echo "${BLUE}👉 GITLAB${NC} (Copia esto y pégalo en Preferences -> SSH Keys):"
echo "--------------------------------------------------------"
cat "${KEY_GITLAB}.pub"
echo "--------------------------------------------------------"
echo ""

if [[ "$PERSONAL_CONFIG" == true ]]; then
    echo "${BLUE}👉 GITHUB PERSONAL${NC} (Copia esto para tu cuenta personal):"
    echo "--------------------------------------------------------"
    cat "${KEY_PERSONAL}.pub"
    echo "--------------------------------------------------------"
    echo ""
fi

echo "${YELLOW}💡 PRUEBA TU CONEXIÓN CON:${NC}"
echo "   ssh -T git@github.com"
echo "   ssh -T git@gitlab.com"
[[ "$PERSONAL_CONFIG" == true ]] && echo "   ssh -T git@github.com-personal"
[[ -n "$GITLAB_SELF_HOSTED" ]] && echo "   ssh -T git@$GITLAB_SELF_HOSTED"

# --- 10. PREGUNTAR SI QUIERE PROBAR CONEXIONES ---
echo ""
echo "${BLUE}🔍 ¿Quieres probar las conexiones ahora? (s/N)${NC}"
read -r respuesta
if [[ "$respuesta" =~ ^[Ss]$ ]]; then
    echo ""
    echo "${YELLOW}Probando conexiones...${NC}"
    echo ""
    
    echo "${BLUE}GitHub:${NC}"
    ssh -T git@github.com 2>&1 | head -1
    echo ""
    
    echo "${BLUE}GitLab:${NC}"
    ssh -T git@gitlab.com 2>&1 | head -1
    
    if [[ "$PERSONAL_CONFIG" == true ]]; then
        echo ""
        echo "${BLUE}GitHub Personal:${NC}"
        ssh -T git@github.com-personal 2>&1 | head -1
    fi
    
    if [[ -n "$GITLAB_SELF_HOSTED" ]]; then
        echo ""
        echo "${BLUE}GitLab Self-Hosted ($GITLAB_SELF_HOSTED):${NC}"
        ssh -T git@$GITLAB_SELF_HOSTED 2>&1 | head -1
    fi
    
    echo ""
    echo "${YELLOW}ℹ️  Nota: Es normal que aparezca 'Permission denied' si aún no has añadido las claves públicas.${NC}"
    echo "   El mensaje debe mencionar tu nombre de usuario si la conexión SSH funciona."
fi

echo ""
echo "${GREEN}✅ Script finalizado. ¡Feliz coding! 🚀${NC}"