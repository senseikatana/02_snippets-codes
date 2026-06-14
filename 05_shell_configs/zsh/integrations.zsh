# ==============================================
# 🔌 INTEGRACIONES Y CARGA PEREZOSA
# ==============================================

# FZF
if [[ -f "$HOME/.fzf.zsh" ]]; then
    source "$HOME/.fzf.zsh"
fi

# Zoxide
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# NVM Lazy Loading (Para que la terminal abra al instante)
load_nvm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
}
nvm() { load_nvm; nvm "$@"; }
node() { load_nvm; node "$@"; }
npm() { load_nvm; npm "$@"; }
npx() { load_nvm; npx "$@"; }

# Bun completions
[ -s "/home/senseikatana/.bun/_bun" ] && source "/home/senseikatana/.bun/_bun"