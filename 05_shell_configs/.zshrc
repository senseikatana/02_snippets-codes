
# ==============================================
# ⚡ POWERLEVEL10K INSTANT PROMPT
# ==============================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==============================================
# 📦 ZINIT - GESTOR DE PLUGINS
# ==============================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Plugins principales
zinit ice depth=1
zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions

# Yazi File Manager
zinit ice from"gh-r" as"program" bpick"*linux*" sbin"yazi"
zinit light sxyazi/yazi

# Snippets Oh-My-Zsh
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Completions
autoload -Uz compinit
compinit -u
zinit cdreplay -q >/dev/null 2>&1

# Powerlevel10k Config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# ==============================================
# ⚙️ CONFIGURACIONES DEL SHELL
# ==============================================

# --- Keybindings ---
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey "^I" expand-or-complete

# --- History ---
HISTSIZE=5000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY

# --- Completion styling ---
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

if zstyle -t ':completion:*' fzf-preview 2>/dev/null; then
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color "$realpath"'
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color "$realpath"'
fi


# ==============================================
# 🥷 .ZSHRC PRINCIPAL (SenseiKatana Dojo)
# ==============================================

# 4. Funciones personalizadas (Modularizadas)
source "$HOME/.zsh/functions/sysinfo.zsh"
source "$HOME/.zsh/functions/dev_tools.zsh"
source "$HOME/.zsh/functions/pkg_managers.zsh"
source "$HOME/.zsh/functions/git_helpers.zsh"
source "$HOME/.zsh/functions/manager.zsh"

# 5. Aliases organizados
source "$HOME/.zsh/aliases.zsh"

# 6. Integraciones externas (FZF, Zoxide, NVM Lazy Load)
source "$HOME/.zsh/integrations.zsh"

# ==============================================
# 🎌 GREETING (Al final para que no bloquee la carga)
# ==============================================
if [[ -o interactive ]]; then
    gum style \
        --foreground 212 --border-foreground 57 \
        --border double --align center --width 40 --margin "1 2" --padding "1 2" \
        "╭───────────╮" \
        "│  ◕  ◡  ◕  │" \
        "╰───────────╯" \
        "¡Ohayou, Samurai Katana!" \
        "Arigato por entrar al Dojo." | lolcat
fi


# ==============================================
# 🌍 VARIABLES DE ENTORNO Y PATH
# ==============================================
export GIT_DISCOVERY_ACROSS_FILESYSTEM=1
export EDITOR="fresh"

# Paths generales
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.lmstudio/bin"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH=/home/senseikatana/.opencode/bin:$PATH

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# PNPM
export PNPM_HOME="/home/senseikatana/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# NVM (Directorio base, la carga perezosa va en integraciones)
export NVM_DIR="$HOME/.nvm"