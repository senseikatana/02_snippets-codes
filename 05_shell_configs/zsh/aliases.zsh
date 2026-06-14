
# ==============================================
# 📂 ARCHIVOS Y DIRECTORIOS
# ==============================================
alias cls='clear; la'
alias h='history'
alias ls='eza --icons -lh'
alias la='eza --icons -lha'
alias mkdir='mkdir -pv'
alias copy='cp -iv'
alias move='mv -iv'
alias remove='rm -i'
alias rename='mv -iv'

# ==============================================
# 🔍 BÚSQUEDA AVANZADA
# ==============================================
alias find='fd'
alias grep='rg'

# ==============================================
# 🛠️ CORRECCIÓN Y AYUDA
# ==============================================
alias fuck='$(thefuck $(fc -ln -1))'
alias please='sudo $(fc -ln -1)'

# ==============================================
# 📦 PACKAGE MANAGERS
# ==============================================
alias pkg-i='pkg i'
alias pkg-r='pkg r'
alias pkg-u='pkg u'
alias pkg-update="/home/senseikatana/Github/02_snippets-codes/02_os_installers/arch/update-automate.sh"
alias pkg-c='pkg c'
alias pkg-k='pkg k'
alias pkg-conf='pkg conf'
alias pkg-pamac='pkg pamac'
alias pkgdeb-i='pkg-deb i' 
alias pkgdeb-r='pkg-deb r'
alias pkgdeb-u='pkg-deb u'
alias pkgdeb-c='pkg-deb c'
alias pkgdeb-s='pkg-deb s'

# ==============================================
# 💾 DISCOS Y ESPACIO
# ==============================================
alias df='duf'
alias du='dust'
alias ncdu='gdu'

# ==============================================
# 🎮 DIVERSIÓN Y CURIOSIDADES
# ==============================================
alias cow='fortune | cowsay | lolcat'
alias hackertyper='cat /dev/urandom | hexdump -C | grep "ca fe"'
alias map='telnet mapscii.me'
alias matrix='cmatrix -a -b -s'
alias weather='curl wttr.in'

# ==============================================
# ✏️ EDITORES
# ==============================================
alias nano='fresh'

# ==============================================
# 🔧 FUNCIONES PERSONALIZADAS (Aliases)
# ==============================================
alias create-astro='create-web astro'
alias create-next='create-web next'
alias create-react='create-web react'
alias create-svelte='create-web svelte'
alias create-vite='create-web vite'
alias create-vue='create-web vue'
alias dl='download'
alias dlm='download music'
alias dlp='download playlist'
alias dlv='download video'
alias verify='verify_hash'
alias qemu-create='vm create'
alias qemu-full='vm full'
alias qemu-run='vm run'

# ==============================================
# 🚀 DEPLOY & GIT ALIASES
# ==============================================
alias deploy-main='git switch main && git pull origin main && git merge "$(git branch --show-current)" && git push origin main'
alias deploy-dev='git switch dev && git pull origin dev && git merge "$(git branch --show-current)" && git push origin dev'
alias deploy-develop='git switch develop && git pull origin develop && git merge "$(git branch --show-current)" && git push origin develop'
alias gaa='git add .'
alias gad='git add'
alias gam='git commit --amend'
alias gsp='git stash pop'
alias gsa='git stash apply'
alias gsl='git stash list'
alias gss='git stash push -m'
alias gst='git status -sb'
alias glg='git log --oneline --decorate --all --graph'
alias gln='git log --oneline -n 10'
alias gls='git log --oneline --stat'
alias gdf='git diff'
alias gds='git diff --staged'
alias gsh='git show'
alias gbl='git blame'
alias gco='git switch'
alias gnb='git checkout -b'
alias gbr='git branch'
alias gbra='git branch -a'
alias gbrd='git branch -d'
alias gbrD='git branch -D'
alias gbrm='git branch -m'
alias gft='git fetch --all --prune'
alias gpsf='git push --force-with-lease'
alias gpst='git push --tags'
alias gtp='git push --tags'
alias grm='git remote'
alias grma='git remote add'
alias grmd='git remote remove'
alias grmrn='git remote rename'
alias grmv='git remote -v'
alias grs='git reset'
alias grh='git reset --hard HEAD~1'
alias grf='git reset --hard'
alias gundo='git reset --soft HEAD~1'
alias gcl='git clean -fd'
alias gmg='git merge'
alias gmg-dev='git merge dev --no-ff -m'
alias gmg-develop='git merge develop --no-ff -m'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias gcp='git cherry-pick'
alias gtg='git tag'
alias gtl='git tag -l'
alias gtd='git tag -d'
alias gtpd='git push --delete origin'
alias lazyg='lazygit'

# ==============================================
# 💻 LENGUAJES Y RUNTIMES
# ==============================================
alias gob='go build'; alias gof='go fmt ./...'; alias gog='go get'; alias goi='go install'; alias gom='go mod tidy'; alias gor='go run'; alias got='go test ./...'
alias bn='bun'; alias bnbuild='bun build'; alias bnh='bun --help'; alias bnhtml='bun --hot'; alias bni='bun install'; alias bnia='bun add'; alias bniad='bun add -d'; alias bniag='bun add -g'; alias bninit='bun init'; alias bnjs='bun run'; alias bnls='bun pm ls'; alias bnp='bun pm'; alias bnr='bun run'; alias bnrb='bun run build'; alias bnrd='bun run dev'; alias bnrm='bun remove'; alias bnrs='bun run start'; alias bnrt='bun test'; alias bnrtw='bun test --watch'; alias bnu='bun update'; alias bnup='bun upgrade'; alias bnx='bun x'
alias nd='node'; alias ndi='npm install'; alias ndr='npm run'; alias ndv='node -v'
alias nm-delete='rm -rf node_modules'; alias nm-clean='find . -name "node_modules" -type d -prune -exec rm -rf {} +'; alias nm-size='du -sh node_modules 2>/dev/null || echo "No hay node_modules"'; alias nm-list='find . -name "node_modules" -type d -prune -exec du -sh {} \; | sort -hr'; alias clean-all-npm='rm -rf node_modules package-lock.json yarn.lock pnpm-lock.yaml .npm .yarn/cache && npm cache clean --force'
alias python='python3'; alias pip='pip'
alias pn='pnpm'; alias pni='pnpm add'; alias pnid='pnpm add -D'; alias pnig='pnpm add -g'; alias pnls='pnpm list'; alias pnr='pnpm run'; alias pnrb='pnpm run build'; alias pnrd='pnpm run dev'; alias pnrm='pnpm remove'; alias pnrs='pnpm run start'; alias pnrt='pnpm run test'; alias pnup='pnpm update'; alias pnwhy='pnpm why'; alias pnx='pnpm dlx'
alias c='cargo'; alias ca='cargo add'; alias cb='cargo build'; alias cc='cargo clippy'; alias cf='cargo fmt'; alias ci='cargo install'; alias cr='cargo run'; alias ct='cargo test'; alias cw='cargo watch -x run'

# ==============================================
# ⚡ PROCESOS, RED Y SISTEMA
# ==============================================
alias btop='btm'; alias kill9='kill -9'; alias prc='htop'; alias psg='ps aux | grep -i'
alias cht='cht.sh'; alias myip='curl ifconfig.me'; alias ping='ping -c 5'; alias ports='netstat -tulanp'; alias wget='wget'; alias ytmp3='yt-dlp -x --audio-format mp3'; alias ytmp4='yt-dlp'
alias d='docker'; alias dps='docker ps'; alias dpa='docker ps -a'; alias di='docker images'; alias dr='docker run -it --rm'; alias dex='docker exec -it'; alias dlogs='docker logs -f'; alias drm='docker rm'; alias drmi='docker rmi'; alias dstop='docker stop'; alias dstart='docker start'; alias dbuild='docker build -t'; alias dcomp='docker-compose'; alias dcomps='docker-compose ps'; alias dcompb='docker-compose build'; alias dcompup='docker-compose up -d'; alias dcompdown='docker-compose down'; alias dcomplogs='docker-compose logs -f'
alias bsh-cnf='fresh ~/.bashrc'; alias zsh-cnf='fresh ~/.zshrc'; alias reload='source ~/.zshrc && source ~/.bashrc && echo "🔄 Configuración recargada"'; alias env='printenv'
alias grub-update-deb='sudo fresh /etc/default/grub && sudo update-grub'; alias grub-update-pac='sudo fresh /etc/default/grub && sudo grub-mkconfig -o /boot/grub/grub.cfg'; alias poweroff='sudo poweroff'; alias reboot='sudo reboot'; alias visudo='sudo visudo'
alias sys-stop='sudo systemctl stop'; alias sys-enable='sudo systemctl enable --now'; alias sys-disable='sudo systemctl disable'; alias sys-restart='sudo systemctl restart'; alias sys-start='sudo systemctl start'; alias sys-status='sudo systemctl status'; alias sys-suspend='sudo systemctl suspend'; alias sys-user-start='systemctl --user start'; alias sys-user-status='systemctl --user status'; alias sys-user-restart='systemctl --user restart'; alias sys-user-suspend='systemctl --user suspend'; alias sys-user-enable='systemctl --user enable'; alias sys-user-disable='systemctl --user disable'

# ==============================================
# 🌐 INSTALLERS (Wget/Curl)
# ==============================================
alias wget-i-pnpm='wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'
alias wget-i-bun='wget -qO- https://bun.sh/install | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'
alias wget-i-nvm='wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'
alias curl-i-pnpm='curl -fsSL https://get.pnpm.io/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'
alias curl-i-bun='curl -fsSL https://bun.sh/install | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'
alias curl-i-nvm='curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'
alias curl-i-zinit='curl -fsSL https://git.io/zinit-install | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'
alias curl-i-astro='curl -fsSL https://astro.build/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'
alias curl-i-vite='curl -fsSL https://vitejs.dev/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'
alias curl-i-next='curl -fsSL https://nextjs.org/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'
alias curl-i-react='curl -fsSL https://reactjs.org/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'
alias curl-i-svelte='curl -fsSL https://svelte.dev/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'
alias curl-i-vue='curl -fsSL https://vuejs.org/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'

# ==============================================
# 📦 ZINIT ALIASES
# ==============================================
alias zup="zinit update"
alias zsup="zinit self-update"
alias zupall="zinit self-update && zinit update"
alias zls="zinit ls"
alias zcl="zinit delete --clean"
alias zcc="zinit cclear"
alias zcomp="zinit creinstall -q ."
alias zst="zinit times"

alias zfuncs='zfuncs'