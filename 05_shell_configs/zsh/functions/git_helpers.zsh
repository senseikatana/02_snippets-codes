# ==============================================
# 🐙 GIT HELPERS
# ==============================================
function gpl() { git pull origin "$(git branch --show-current)" "$@"; }
function gps() { git push origin "$(git branch --show-current)" "$@"; }
function gpsu() { git push -u origin "$(git branch --show-current)" "$@"; }
function gpp() { git pull origin "$(git branch --show-current)" && git push origin "$(git branch --show-current)"; }

_git_branch_type() {
  local b=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  case "$b" in feature/*|minor/*) echo "feat";; patch/*|hotfix/*) echo "fix";; docs/*) echo "docs";; refactor/*) echo "refactor";; test/*) echo "test";; *) echo "";; esac
}

_git_build_msg() {
  local files=("${(@f)$(git diff --cached --name-only 2>/dev/null || git diff --name-only 2>/dev/null)}")
  [[ ${#files} -eq 0 ]] && { echo "update project"; return }
  local dirs=("${(@u)${files%/*}}") msg=""
  for d in $dirs; do
    case "$d" in *install*) msg="${msg}install, ";; *scripts*|*shell*) msg="${msg}scripts, ";; esac
  done
  echo "${msg%, } files" | sed 's/^, //; s/, files$/ files/'
}

function gcm() {
  [[ "$1" == "-h" ]] && { echo "Uso: gcm [mensaje] (Auto-detecta contexto y usa Gum)"; return 0; }
  local prefix=$(_git_branch_type)
  local msg=$(_git_build_msg)
  local full="${prefix:+$prefix: }${1:-$msg}"
  
  if command -v gum &>/dev/null; then
    full=$(gum input --placeholder "Mensaje del commit" --value "$full")
    [[ -z "$full" ]] && { echo "❌ Abortado"; return 1; }
  fi
  git commit -m "$full"
}

function gac() { git add . && gcm "$@"; }