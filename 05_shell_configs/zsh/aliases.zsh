# ==============================================================================
# 📦 GIT & VERSION CONTROL
# ==============================================================================
alias add='git add'  # Add file changes to the staging area.
alias add-a='git add .'  # Add all changes in the current directory (including untracked files) to the staging area.
alias blame='git blame'  # Show revision and author information for each line of a file.
alias br='git branch'  # List, create, or delete git branches.
alias br-Dl='git branch -D'  # Force delete a git branch locally.
alias br-dl='git branch -d'  # Delete a git branch locally (safely, checking if merged).
alias br-ls='git branch -a'  # List all local and remote git branches.
alias br-new='git checkout -b'  # Create and switch to a new git branch.
alias br-rename='git branch -m'  # Rename the current git branch.
alias cherryp='git cherry-pick'  # Apply the changes introduced by some existing commits.
alias co='git checkout'  # Switch branches or restore working tree files.
alias com='git commit'  # Record changes to the repository with a commit message.
alias com-am='git commit --amend'  # Amend the last git commit (modify commit message or stage new changes).
alias fetch='git fetch'  # Download objects and refs from another repository.
alias fetch-apr='git fetch --all --prune'  # Fetch all remotes and prune obsolete tracking branches.
alias gclean='git clean -fd'  # Forcefully remove untracked files and directories from the working tree.
alias gdf='git diff'  # Show changes between commits, commit and working tree, etc.
alias gds='git diff --staged'  # Show changes between the staging area (index) and the last commit.
alias lazyg='lazygit'  # Open lazygit, a simple and interactive terminal UI for git.
alias log='git log --oneline --decorate --all --graph'  # Show commit history with a graphical structure, decorations, and one line per commit.
alias log-n='git log --oneline -n 10'  # Show the last 10 commit messages in one line format.
alias log-s='git log --oneline --stat'  # Show git commit history with stats on modified files.
alias mrg='git merge'  # Join two or more development histories (branches) together.
alias mrg-nff='git merge --no-ff -m'  # Merge a branch without fast-forwarding, creating a merge commit.
alias pll-or='git pull origin "$(git branch --show-current)"'  # Pull updates from the origin remote for the current active branch.
alias psh-or='git push origin "$(git branch --show-current)"'  # Push the current active branch to the origin remote.
alias psh-uo='git push -u origin "$(git branch --show-current)"'  # Push the current branch and set origin as the upstream tracking branch.
alias pul='git pull'  # Fetch from and integrate (merge/rebase) with another repository or branch.
alias pul-o='git pull origin'  # Pull updates from origin remote.
alias pul-oma='git pull origin main'  # Pull updates from origin main branch.
alias pul-rbs='git pull --rebase'  # Pull changes and rebase local commits on top of them.
alias pus-fwl='git push --force-with-lease'  # Push commits safely using force-with-lease option.
alias rebase='git rebase'  # Reapply commits on top of another base tip.
alias rebase-a='git rebase --abort'  # Abort the current rebase operation.
alias rebase-c='git rebase --continue'  # Continue the rebase operation after resolving conflicts.
alias rebase-s='git rebase --skip'  # Skip the current patch/commit in the rebase process.
alias remote='git remote'  # Manage the set of tracked remote repositories.
alias remote-a='git remote add'  # Add a new remote repository tracking path.
alias remote-rm='git remote remove'  # Remove a tracked remote repository by name.
alias remote-rn='git remote rename'  # Rename a tracked remote repository.
alias remote-v='git remote -v'  # List all tracked remote repositories and their URLs in verbose format.
alias reset='git reset'  # Reset current HEAD to the specified state.
alias reset-hH='git reset --hard HEAD~1'  # Undo the last commit and discard all uncommitted changes (hard reset).
alias reset-hd='git reset --hard'  # Reset the working directory and staging index to match HEAD, discarding changes.
alias reset-sf='git reset --soft HEAD~1'  # Undo the last commit while keeping changes staged in the index (soft reset).
alias show='git show'  # Show details and changes of a specific git commit or object.
alias sta-ap='git stash apply'  # Apply the changes saved in the latest stash without removing it.
alias sta-ls='git stash list'  # List all stashes currently saved in the repository.
alias sta-pp='git stash pop'  # Apply changes from the latest stash and remove it from the stash list.
alias sta-ps='git stash push -m'  # Push local changes into a new stash with a descriptive message.
alias sts-sb='git status -sb'  # Show git status in short format with branch information.
alias tag-Dl='git push --delete origin'  # Delete a git tag from the origin remote repository.
alias tag-cr='git tag'  # List, create, or delete tag objects in Git.
alias tag-dl='git tag -d'  # Delete a git tag locally.
alias tag-ls='git tag -l'  # List all local git tags.
alias tag-ps='git push --tags'  # Push all local tags to the remote repository.

# ==============================================================================
# 📦 DOCKER & CONTAINER MANAGEMENT
# ==============================================================================
alias d='docker'  # Run the Docker command-line utility for managing containers.
alias dbuild='docker build -t'  # Build a Docker image from a local Dockerfile with a tag name.
alias dclean='dclean'  # Run interactive wizard to prune unused Docker data.
alias dcomp='docker-compose'  # Run docker-compose to manage multi-container applications.
alias dcompb='docker-compose build'  # Build or rebuild services defined in docker-compose.
alias dcompdown='docker-compose down'  # Stop and remove containers, networks, images, and volumes created by docker-compose.
alias dcomplogs='docker-compose logs -f'  # View and follow logs output by services in docker-compose.
alias dcomps='docker-compose ps'  # List containers and status for services in docker-compose.
alias dcompup='docker-compose up -d'  # Create, start, and run containers in the background using docker-compose.
alias dex='dexec'  # Run interactive command inside running container or select one interactively.
alias di='docker images'  # List all locally cached Docker images.
alias dip='dip'  # Display running Docker container IP addresses and port mappings.
alias dlogs='dlog'  # View and follow logs for a specific container or select one interactively.
alias dpa='docker ps -a'  # List all Docker containers (both running and stopped).
alias dps='docker ps'  # List currently running Docker containers.
alias dr='docker run -it --rm'  # Run a Docker container interactively and automatically remove it on exit.
alias drm='docker rm'  # Remove one or more stopped Docker containers.
alias drmi='docker rmi'  # Remove one or more locally cached Docker images.
alias dstart='docker start'  # Start one or more stopped Docker containers.
alias dstop='docker stop'  # Stop one or more running Docker containers.

# ==============================================================================
# 📦 BUN PACKAGE MANAGER & RUNTIME
# ==============================================================================
alias bun-a='bun add'  # Add/install a package using Bun.
alias bun-ad='bun add -d'  # Add/install a development dependency using Bun.
alias bun-ag='bun add -g'  # Add/install a package globally using Bun.
alias bun-bd='bun build'  # Bundle/build project assets using the Bun builder.
alias bun-hot='bun --hot'  # Run Bun in hot-reloading mode for development.
alias bun-hp='bun --help'  # Display the help documentation for Bun commands.
alias bun-in='bun install'  # Install all dependencies defined in package.json using Bun.
alias bun-ini='bun init'  # Initialize a new Bun project interactively.
alias bun-js='bun run'  # Run a script or file using Bun.
alias bun-ls='bun pm ls'  # List all installed packages and their versions under Bun package manager.
alias bun-pm='bun pm'  # Interact with the Bun package manager.
alias bun-r='bun run'  # Run a script or binary defined in package.json using Bun.
alias bun-rb='bun run build'  # Run the build script defined in package.json using Bun.
alias bun-rd='bun run dev'  # Start the development server/script defined in package.json using Bun.
alias bun-rm='bun remove'  # Remove/uninstall a package using Bun.
alias bun-rs='bun run start'  # Run the start script defined in package.json using Bun.
alias bun-ts='bun test'  # Run test suites using the Bun test runner.
alias bun-tsw='bun test --watch'  # Run test suites in watch mode using the Bun test runner.
alias bun-u='bun update'  # Update installed package dependencies using Bun.
alias bun-up='bun upgrade'  # Upgrade the Bun binary to the latest version.
alias bun-x='bun x'  # Execute a package binary using Bun without installing it globally.

# ==============================================================================
# 📦 CARGO & RUST ECOSYSTEM
# ==============================================================================
alias c='cargo'  # Invoke the Cargo tool for Rust package and project management.
alias ca='cargo add'  # Add a new dependency to Cargo.toml using Cargo.
alias cb='cargo build'  # Compile/build the current Rust project using Cargo.
alias cc='cargo clippy'  # Run Clippy linter to analyze and catch common mistakes in Rust code.
alias cf='cargo fmt'  # Format Rust source files to match official style guidelines.
alias ci='cargo install'  # Build and install a Rust binary or command locally.
alias cr='cargo run'  # Compile and run the current Rust project binary.
alias ct='cargo test'  # Run tests defined in the current Rust project using Cargo.
alias cw='cargo watch -x run'  # Watch Rust source files and execute 'cargo run' on any changes.

# ==============================================================================
# 📦 NODE.JS, NPM & PNPM PACKAGE MANAGERS
# ==============================================================================
alias nd='node'  # Invoke the Node.js JavaScript runtime environment.
alias ndi='npm install'  # Install package dependencies defined in package.json using npm.
alias ndr='npm run'  # Run a custom script defined in package.json using npm.
alias ndv='node -v'  # Display the currently installed version of Node.js.
alias nm-clean='find . -name "node_modules" -type d -prune -exec rm -rf {} +'  # Find and recursively delete all node_modules directories in the current folder.
alias nm-clean-all='rm -rf node_modules package-lock.json yarn.lock pnpm-lock.yaml .npm .yarn/cache && npm cache clean --force'  # Clean all node_modules, lockfiles, global npm/yarn cache, and reset environment.
alias nm-delete='rm -rf node_modules'  # Delete the node_modules directory in the current workspace.
alias nm-list='find . -name "node_modules" -type d -prune -exec du -sh {} \; | sort -hr'  # Find and list all node_modules directories sorted by their disk space size.
alias nm-size='du -sh node_modules 2>/dev/null || echo "No hay node_modules"'  # Calculate and show the total disk space size of the node_modules folder.
alias pnp='pnpm'  # Run the fast, disk space efficient pnpm package manager.
alias pnp-a='pnpm add'  # Install a package and add it to project dependencies using pnpm.
alias pnp-aD='pnpm add -D'  # Install a package as a development dependency using pnpm.
alias pnp-aG='pnpm add -g'  # Install a package globally using pnpm.
alias pnp-dx='pnpm dlx'  # Execute a package binary from npm without local install using pnpm dlx.
alias pnp-ls='pnpm list'  # List installed package dependencies and their versions using pnpm.
alias pnp-r='pnpm run'  # Run a script defined in package.json using pnpm.
alias pnp-rb='pnpm run build'  # Build the project by running the build script with pnpm.
alias pnp-rd='pnpm run dev'  # Start the local development server script with pnpm.
alias pnp-rm='pnpm remove'  # Remove/uninstall a package from the project using pnpm.
alias pnp-rs='pnpm run start'  # Run the start script defined in package.json using pnpm.
alias pnp-ts='pnpm run test'  # Execute tests by running the test script with pnpm.
alias pnp-u='pnpm update'  # Update project dependencies to their latest versions using pnpm.
alias pnp-why='pnpm why'  # Show the dependency tree path explaining why a package is installed using pnpm.

# ==============================================================================
# 📦 SYSTEMD SERVICE MANAGEMENT
# ==============================================================================
alias sys-disable='sudo systemctl disable'  # Disable a systemd service from starting automatically at boot.
alias sys-enable='sudo systemctl enable --now'  # Enable a systemd service to start at boot and start it immediately.
alias sys-restart='sudo systemctl restart'  # Restart a running systemd service.
alias sys-start='sudo systemctl start'  # Start a systemd service immediately.
alias sys-status='sudo systemctl status'  # Show the current runtime status of a systemd service.
alias sys-stop='sudo systemctl stop'  # Stop a running systemd service.
alias sys-suspend='sudo systemctl suspend'  # Suspend/put the system into a low-power sleep state.
alias sys-user-disable='systemctl --user disable'  # Disable a systemd user service from starting automatically at login.
alias sys-user-enable='systemctl --user enable'  # Enable a systemd user service to start automatically at login.
alias sys-user-restart='systemctl --user restart'  # Restart a systemd user service.
alias sys-user-start='systemctl --user start'  # Start a systemd user service immediately.
alias sys-user-status='systemctl --user status'  # Show the current runtime status of a systemd user service.
alias sys-user-suspend='systemctl --user suspend'  # Suspend systemd user services or user session.

# ==============================================================================
# 📦 ZINIT PLUGIN MANAGER
# ==============================================================================
alias zcc="zinit cclear"  # Clear the Zinit plugin and completions cache.
alias zcl="zinit delete --clean"  # Delete unused Zinit plugins and perform a clean-up.
alias zcomp="zinit creinstall -q ."  # Reinstall and rebuild completions silently for Zinit.
alias zls="zinit ls"  # List all plugins currently managed and loaded by Zinit.
alias zst="zinit times"  # Display startup times for Zinit plugins to optimize performance.
alias zsup="zinit self-update"  # Self-update the Zinit plugin manager to the latest version.
alias zup="zinit update"  # Update all plugins managed by Zinit.
alias zupall="zinit self-update && zinit update"  # Perform self-update of Zinit and update all installed plugins.

# ==============================================================================
# 📦 CUSTOM TOOL WRAPPERS & INTEGRATIONS
# ==============================================================================
alias angy='agy'  # Launch the Google Antigravity (AGY) SDK CLI interface.
alias oc='opencode'  # Run the opencode command-line utility.
alias oclaw='openclaw'  # Run the openclaw command-line game/utility.
alias useDownload='download'  # Download files using a custom downloader script.
alias useGitAddCom="git-magic -a"  # Add changes and commit them with a message using git-magic wrapper.
alias useGitDeploy="git-magic -a -p"  # Add changes, commit, and push them to remote using git-magic wrapper.
alias useGitPushing="git-magic -p -d"  # Push changes and deploy them to a target branch using git-magic wrapper.
alias useHashCalc='verifyhash'  # Calculate and verify file checksums / hashes.
alias useInfoSys='sysinfo'  # Show detailed system information.
alias useListApps='list-apps'  # List all installed applications on the system.
alias usePkg='pkg'  # Manage system packages using a custom pkg tool.
alias usePkgDeb='pkg-deb'  # Manage Debian packages using a custom pkg-deb tool.
alias useVM='vm'  # Manage virtual machines using a custom VM wrapper.
alias useZFns='zfuncs'  # List or reload Zsh custom shell functions.

# ==============================================================================
# 📦 ONE-LINER INSTALLERS (CURL & WGET)
# ==============================================================================
alias curl-i-astro='curl -fsSL https://astro.build/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'  # Download and run the Astro installation script using curl.
alias curl-i-bun='curl -fsSL https://bun.sh/install | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'  # Download and run the Bun installation script using curl.
alias curl-i-next='curl -fsSL https://nextjs.org/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'  # Download and run the Next installation script using curl.
alias curl-i-nvm='curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'  # Download and run the Nvm installation script using curl.
alias curl-i-pnpm='curl -fsSL https://get.pnpm.io/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'  # Download and run the Pnpm installation script using curl.
alias curl-i-react='curl -fsSL https://reactjs.org/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'  # Download and run the React installation script using curl.
alias curl-i-svelte='curl -fsSL https://svelte.dev/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'  # Download and run the Svelte installation script using curl.
alias curl-i-vite='curl -fsSL https://vitejs.dev/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'  # Download and run the Vite installation script using curl.
alias curl-i-vue='curl -fsSL https://vuejs.org/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'  # Download and run the Vue installation script using curl.
alias curl-i-zinit='curl -fsSL https://git.io/zinit-install | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'  # Download and run the Zinit installation script using curl.
alias wget-i-bun='wget -qO- https://bun.sh/install | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'  # Download and run the Bun installation script using wget.
alias wget-i-nvm='wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'  # Download and run the NVM installation script using wget.
alias wget-i-pnpm='wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -'  # Download and run the PNPM installation script using wget.

# ==============================================================================
# 📦 GENERAL SYSTEM UTILITIES & HELPERS
# ==============================================================================
alias bsh-cnf='fresh ~/.bashrc'  # Edit the Bash configuration file (.bashrc) using the fresh editor.
alias btop='btm'  # Run bottom (btm), a graphical system monitor.
alias cht='cht.sh'  # Query the cheat sheet service cht.sh directly from the terminal.
alias cls='clear; ls'  # Clear the screen and list files in the directory with detailed view.
alias copy='cp -iv'  # Copy files interactively, prompting before overwrite, with verbose output.
alias cow='fortune | cowsay | lolcat'  # Display a random quote inside an ASCII cow balloon with rainbow colors.
alias df='duf'  # Display disk space usage in a modern, user-friendly layout using duf.
alias du='dust'  # Show folder and file size distribution using the dust utility.
alias env='printenv'  # Print all active environment variables.
alias find='fd'  # Find files and directories using fd, a fast alternative to find.
alias fuck='$(thefuck $(fc -ln -1))'  # Correct the last misspelled console command using thefuck.
alias gob='go build'  # Compile Go packages and dependencies.
alias gof='go fmt ./...'  # Format Go source code files recursively in the current directory tree.
alias gog='go get'  # Download and install Go modules and dependencies.
alias goi='go install'  # Compile and install Go packages and commands.
alias grep='rg'  # Search for text patterns inside files using ripgrep (rg).
alias grub-update-deb='sudo fresh /etc/default/grub && sudo update-grub'  # Edit grub configuration and update grub bootloader on Debian-based systems.
alias grub-update-pac='sudo fresh /etc/default/grub && sudo grub-mkconfig -o /boot/grub/grub.cfg'  # Edit grub configuration and regenerate grub menu on Arch Linux-based systems.
alias h='history'  # Show terminal command history.
alias hackertyper='cat /dev/urandom | hexdump -C | grep "ca fe"'  # Stream random data to terminal to simulate a movie hacking screen.
alias kill9='kill -9'  # Forcefully terminate a process by its PID using SIGKILL (-9).
alias la='eza --icons -lha'  # List all files (including hidden ones) with icons, size, and details.
alias ls='eza --icons -lh'  # List files in the current directory with icons and details.
alias map='telnet mapscii.me'  # Display an interactive, zoomable vector map of the world in the console.
alias matrix='cmatrix -a -b -s'  # Show the classic matrix screen saver animation in the terminal.
alias mkdir='mkdir -pv'  # Create new directories interactively, printing a message for each.
alias move='mv -iv'  # Move or rename files interactively, prompting before overwrite.
alias myip='curl ifconfig.me'  # Retrieve and display the public IP address of the system.
alias nano='fresh'  # Open files using the fresh editor (replaces nano).
alias ncdu='gdu'  # Inspect disk usage interactively using the fast gdu utility.
alias open='xdg-open'  # Open files or URLs in the default system application.
alias ping='ping -c 5'  # Send 5 ICMP echo requests to verify network connectivity.
alias pip='pip'  # Install and manage Python packages using pip.
alias pkg-update="/home/senseikatana/Github/02_snippets-codes/02_os_installers/arch/update-automate.sh"  # Run the automated update script for Arch Linux packages.
alias please='sudo $(fc -ln -1)'  # Rerun the last command in terminal with sudo privileges.
alias ports='netstat -tulanp'  # Show active network ports and the processes listening on them.
alias poweroff='sudo poweroff'  # Power down the computer immediately using sudo.
alias prc='htop'  # Show the interactive htop process monitor.
alias psg='ps aux | grep -i'  # List active processes and grep through them case-insensitively.
alias python='python3'  # Alias for python3
alias reboot='sudo reboot'  # Restart the system immediately using sudo.
alias reload='source ~/.zshrc && source ~/.bashrc && echo "🔄 Configuración recargada"'  # Reload the zshrc and bashrc configurations and echo confirmation.
alias remove='rm -i'  # Remove files or directories, asking for confirmation before each deletion.
alias rename='mv -iv'  # Move or rename files interactively with verbose output.
alias visudo='sudo visudo'  # Edit the system sudoers configuration file safely.
alias weather='curl wttr.in'  # Fetch and display the weather forecast in the terminal using wttr.in.
alias wget='wget'  # Download files from the web non-interactively.
alias zsh-cnf='fresh ~/.zshrc'  # Edit the Zsh configuration file (.zshrc) using the fresh editor.
