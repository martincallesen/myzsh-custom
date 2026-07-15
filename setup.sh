#!/usr/bin/env bash
# Install tools required by myzsh-custom and link the repo into Oh My Zsh.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OH_MY_ZSH_DIR="${OH_MY_ZSH_DIR:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$OH_MY_ZSH_DIR/custom}"
ZSHRC="${ZSHRC:-$HOME/.zshrc}"
MARKER="# myzsh-custom"
OH_MY_ZSH_MARKER="# oh-my-zsh (myzsh-custom setup)"

usage() {
  cat <<'EOF'
Usage: ./setup.sh [options]

Install dependencies and wire this repo into your shell.

Options:
  --link-custom     Symlink this repo to ~/.oh-my-zsh/custom (default)
  --no-link-custom  Skip the Oh My Zsh custom symlink
  --write-zshrc     Append a source line for load.zsh to ~/.zshrc
  --no-write-zshrc  Do not modify ~/.zshrc (default)
  -h, --help        Show this help

Examples:
  ./setup.sh
  ./setup.sh --write-zshrc
  ./setup.sh --no-link-custom --write-zshrc
EOF
}

log() { printf '==> %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }

LINK_CUSTOM=1
WRITE_ZSHRC=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --link-custom) LINK_CUSTOM=1 ;;
    --no-link-custom) LINK_CUSTOM=0 ;;
    --write-zshrc) WRITE_ZSHRC=1 ;;
    --no-write-zshrc) WRITE_ZSHRC=0 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

OS="$(uname -s)"
HAS_BREW=0
if command -v brew >/dev/null 2>&1; then
  HAS_BREW=1
elif [[ -x /opt/homebrew/bin/brew ]]; then
  HAS_BREW=1
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  HAS_BREW=1
  eval "$(/usr/local/bin/brew shellenv)"
fi

run_as_root() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    warn "root privileges required for: $*"
    return 1
  fi
}

install_packages() {
  local packages=("$@")
  local missing=()

  for pkg in "${packages[@]}"; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done

  [[ ${#missing[@]} -eq 0 ]] && return 0

  log "installing tools: ${missing[*]}"

  if [[ "$HAS_BREW" -eq 1 ]]; then
    brew install "${missing[@]}"
    return 0
  fi

  if command -v apt-get >/dev/null 2>&1; then
    local apt_packages=()
    for pkg in "${missing[@]}"; do
      case "$pkg" in
        fzf) apt_packages+=(fzf) ;;
        direnv) apt_packages+=(direnv) ;;
        git) apt_packages+=(git) ;;
        zsh) apt_packages+=(zsh) ;;
        curl) apt_packages+=(curl) ;;
        docker) apt_packages+=(docker.io) ;;
        *) warn "no apt mapping for $pkg; install it manually" ;;
      esac
    done
    if [[ ${#apt_packages[@]} -gt 0 ]]; then
      run_as_root apt-get update -qq
      run_as_root apt-get install -y "${apt_packages[@]}"
    fi
    return 0
  fi

  warn "no supported package manager found; install manually: ${missing[*]}"
}

oh_my_zsh_installed() {
  [[ -f "$OH_MY_ZSH_DIR/oh-my-zsh.sh" ]]
}

repair_oh_my_zsh_permissions() {
  if [[ ! -e "$OH_MY_ZSH_DIR" ]]; then
    return 0
  fi

  local owner
  owner="$(stat -c '%U' "$OH_MY_ZSH_DIR" 2>/dev/null || true)"
  if [[ "$owner" != "$(whoami)" ]]; then
    warn "$OH_MY_ZSH_DIR is owned by ${owner:-unknown}, expected $(whoami)"
    if command -v sudo >/dev/null 2>&1; then
      log "fixing ownership of $OH_MY_ZSH_DIR (sudo required)"
      sudo chown -R "$(whoami):$(id -gn)" "$OH_MY_ZSH_DIR"
    else
      warn "run: sudo chown -R $(whoami):$(id -gn) $OH_MY_ZSH_DIR"
      return 1
    fi
  fi

  chmod -R go-w "$OH_MY_ZSH_DIR"
}

install_oh_my_zsh() {
  if oh_my_zsh_installed; then
    log "Oh My Zsh already installed at $OH_MY_ZSH_DIR"
    repair_oh_my_zsh_permissions
    return 0
  fi

  if ! command -v git >/dev/null 2>&1; then
    warn "git is required to install Oh My Zsh"
    return 1
  fi

  if [[ -e "$OH_MY_ZSH_DIR" && ! -w "$OH_MY_ZSH_DIR" ]]; then
    warn "$OH_MY_ZSH_DIR is not writable; fix ownership and re-run setup:"
    warn "  sudo chown -R \"$(whoami):\$(id -gn)\" \"$OH_MY_ZSH_DIR\""
    return 1
  fi

  local preserved_custom=""
  if [[ -e "$ZSH_CUSTOM" ]]; then
    preserved_custom="$(mktemp -d)"
    cp -a "$ZSH_CUSTOM" "$preserved_custom/custom"
  fi

  if [[ -d "$OH_MY_ZSH_DIR/.git" ]]; then
    log "repairing Oh My Zsh checkout at $OH_MY_ZSH_DIR"
    git -C "$OH_MY_ZSH_DIR" pull --ff-only
  elif [[ -d "$OH_MY_ZSH_DIR" ]]; then
    warn "incomplete Oh My Zsh install at $OH_MY_ZSH_DIR; reinstalling"
    rm -rf "$OH_MY_ZSH_DIR"
    log "cloning Oh My Zsh to $OH_MY_ZSH_DIR"
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OH_MY_ZSH_DIR"
  else
    log "cloning Oh My Zsh to $OH_MY_ZSH_DIR"
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OH_MY_ZSH_DIR"
  fi

  if [[ -n "$preserved_custom" ]]; then
    rm -rf "$ZSH_CUSTOM"
    cp -a "$preserved_custom/custom" "$ZSH_CUSTOM"
    rm -rf "$preserved_custom"
  fi

  if ! oh_my_zsh_installed; then
    warn "Oh My Zsh installation failed; expected $OH_MY_ZSH_DIR/oh-my-zsh.sh"
    return 1
  fi

  repair_oh_my_zsh_permissions
}

clone_plugin() {
  local name="$1"
  local url="$2"
  local dest="$ZSH_CUSTOM/plugins/$name"

  if [[ -d "$dest/.git" ]]; then
    log "updating zsh plugin: $name"
    git -C "$dest" pull --ff-only
  elif [[ -d "$dest" ]]; then
    warn "plugin directory exists but is not a git repo: $dest"
  else
    log "cloning zsh plugin: $name"
    mkdir -p "$ZSH_CUSTOM/plugins"
    git clone --depth 1 "$url" "$dest"
  fi
}

install_zsh_plugins() {
  if [[ "$HAS_BREW" -eq 1 ]]; then
    if brew list zsh-autosuggestions >/dev/null 2>&1 \
       && brew list zsh-syntax-highlighting >/dev/null 2>&1; then
      log "zsh plugins already available via Homebrew"
      return 0
    fi
  fi

  if [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
     && -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    log "zsh plugins already available via system packages"
    return 0
  fi

  clone_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
  clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting
}

link_custom_folder() {
  if ! oh_my_zsh_installed; then
    warn "Oh My Zsh is not installed; skipping custom folder link"
    return 0
  fi

  if [[ -L "$ZSH_CUSTOM" && "$(readlink -f "$ZSH_CUSTOM")" == "$REPO_ROOT" ]]; then
    log "custom folder already linked to this repo"
    return 0
  fi

  if [[ -e "$ZSH_CUSTOM" && ! -L "$ZSH_CUSTOM" ]]; then
    local backup="$ZSH_CUSTOM.backup.$(date +%Y%m%d%H%M%S)"
    log "backing up existing custom folder to $backup"
    mv "$ZSH_CUSTOM" "$backup"
  elif [[ -L "$ZSH_CUSTOM" ]]; then
    log "replacing existing custom symlink"
    rm "$ZSH_CUSTOM"
  fi

  log "linking $REPO_ROOT -> $ZSH_CUSTOM"
  ln -sfn "$REPO_ROOT" "$ZSH_CUSTOM"
}

repair_zshrc() {
  if [[ ! -f "$ZSHRC" ]]; then
    return 0
  fi

  if grep -Fq "$OH_MY_ZSH_MARKER" "$ZSHRC" && ! grep -Fq 'ZSH_DISABLE_COMPFIX' "$ZSHRC"; then
    sed -i '/^export ZSH=.*oh-my-zsh/a ZSH_DISABLE_COMPFIX=true' "$ZSHRC"
    log "added ZSH_DISABLE_COMPFIX=true to $ZSHRC"
  fi
}

write_zshrc_entry() {
  if [[ ! -f "$ZSHRC" ]]; then
    log "creating $ZSHRC"
    touch "$ZSHRC"
  fi

  if oh_my_zsh_installed && ! grep -Fq 'oh-my-zsh.sh' "$ZSHRC"; then
    cat >>"$ZSHRC" <<EOF

$OH_MY_ZSH_MARKER
export ZSH="$OH_MY_ZSH_DIR"
ZSH_DISABLE_COMPFIX=true
plugins=(git)
source "\$ZSH/oh-my-zsh.sh"
EOF
    log "added Oh My Zsh bootstrap to $ZSHRC"
  fi

  if [[ "$LINK_CUSTOM" -eq 1 ]]; then
    log "custom folder linked; Oh My Zsh will load load.zsh automatically"
    return 0
  fi

  if grep -Fq "$MARKER" "$ZSHRC"; then
    log "~/.zshrc already sources myzsh-custom"
    return 0
  fi

  cat >>"$ZSHRC" <<EOF

$MARKER
source "$REPO_ROOT/load.zsh"
EOF
  log "appended source line to $ZSHRC"
}

verify_shell_setup() {
  if zsh -i -c 'whence gst' 2>/dev/null | grep -q gst; then
    log "verified: gst alias works in zsh"
    return 0
  fi

  warn "gst alias not available; run: source ~/.zshrc"
  return 1
}

print_next_steps() {
  local login_shell
  login_shell="$(basename "$(getent passwd "$(whoami)" | cut -d: -f7)" 2>/dev/null || true)"

  cat <<EOF

Setup complete.

Reload your shell config in zsh:
  source ~/.zshrc

If that still fails, start a fresh interactive zsh:
  zsh -i

Test Oh My Zsh git aliases:
  gst

Test branch picker (inside a git repo):
  gb

Aliases like gst come from Oh My Zsh and only work after ~/.zshrc is loaded.
Do not run: source load.zsh from bash.

EOF

  if [[ "$login_shell" != "zsh" ]]; then
    cat <<EOF
Your login shell is ${login_shell:-unknown}, not zsh. To make zsh the default:
  chsh -s "\$(command -v zsh)"
Then open a new terminal.

EOF
  fi

  cat <<EOF
Optional tools (install manually if you use the matching scripts):
  docker    - docker.zsh
  sdkman    - sdkman.zsh (https://sdkman.io/install)
  maven     - maven.zsh
  ~/.git-askpass - git.zsh credential helper
EOF
}

main() {
  if [[ "${EUID}" -eq 0 ]]; then
    warn "do not run setup.sh with sudo; run as your normal user"
    exit 1
  fi

  log "myzsh-custom setup (repo: $REPO_ROOT)"

  install_packages git zsh fzf direnv

  if [[ "$OS" == "Darwin" ]]; then
    install_packages brew
  fi

  install_oh_my_zsh

  if ! oh_my_zsh_installed; then
    warn "setup finished without a working Oh My Zsh install"
    warn "fix any ownership issues above, then re-run: ./setup.sh --write-zshrc"
    print_next_steps
    exit 1
  fi

  install_zsh_plugins

  if [[ "$LINK_CUSTOM" -eq 1 ]]; then
    link_custom_folder
  fi

  if [[ "$WRITE_ZSHRC" -eq 1 ]]; then
    write_zshrc_entry
  fi

  repair_zshrc
  verify_shell_setup || true
  print_next_steps
}

main
