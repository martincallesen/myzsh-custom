# myzsh-custom

Personal Zsh configuration split into small, shareable modules. Clone the repo, run setup, and load everything with one entry point.

Many scripts were originally written for macOS, but Linux is supported for the core modules.

## Quick start

```bash
git clone <repo-url> ~/repositories/myzsh-custom
cd ~/repositories/myzsh-custom
./setup.sh --write-zshrc
```

Then reload your config in zsh:

```bash
source ~/.zshrc
gst
```

`load.zsh` uses zsh-only syntax. Do not `source load.zsh` from bash.

## What setup does

`setup.sh` installs common dependencies and wires this repo into your shell:

| Step | Action |
|------|--------|
| Packages | Installs `git`, `zsh`, `fzf`, and `direnv` via Homebrew (macOS) or `apt` (Debian/Ubuntu) |
| Oh My Zsh | Clones to `~/.oh-my-zsh` if missing or incomplete (repairs broken installs) |
| Zsh plugins | Uses Homebrew packages when available, otherwise clones into `plugins/` |
| Oh My Zsh custom | Symlinks this repo to `~/.oh-my-zsh/custom` (default) |
| `~/.zshrc` | With `--write-zshrc`, adds Oh My Zsh bootstrap (if missing) and fixes permissions |

When the custom folder is linked, Oh My Zsh loads `load.zsh` automatically. A separate `source load.zsh` line in `~/.zshrc` is only needed with `--no-link-custom`.

### Setup options

```bash
./setup.sh                  # install tools, link custom folder
./setup.sh --write-zshrc    # also add Oh My Zsh bootstrap to ~/.zshrc
./setup.sh --no-link-custom # skip Oh My Zsh symlink
./setup.sh --help           # show all options
```

If Oh My Zsh installation fails (for example, no network), setup reports the error and how to retry.

Do not run `./setup.sh` with `sudo`. If `~/.oh-my-zsh` was created as root, setup tries to fix ownership or prints the `chown` command to run.

## Loading scripts

`load.zsh` is the single entry point. It sources files from `modules/` in a stable order and keeps `sdkman.zsh` last.

When this repo is linked to `~/.oh-my-zsh/custom`, Oh My Zsh loads `load.zsh` automatically after `oh-my-zsh.sh`.

Your `~/.zshrc` should contain:

```bash
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true
plugins=(git)
source "$ZSH/oh-my-zsh.sh"
```

Aliases like `gst` (`git status`) come from the Oh My Zsh `git` plugin and only work after `~/.zshrc` is loaded in zsh.

### Troubleshooting

| Problem | Fix |
|---------|-----|
| `gst: command not found` | Run `source ~/.zshrc` in zsh, or start `zsh -i` |
| `bad substitution` when sourcing | You are in bash; use zsh |
| `no such file or directory: oh-my-zsh.sh` | Re-run `./setup.sh` |
| `Insecure completion-dependent directories` | Re-run `./setup.sh` to fix ownership, or add `ZSH_DISABLE_COMPFIX=true` to `~/.zshrc` |
| `gb` shows nothing | You are not inside a git repository |
| `Not in a git repository` | Run `gb` / `gco` from inside a git repo |

## Modules

All modules live in `modules/`. Only `load.zsh` sits at the repo root.

| File | Purpose | Requires |
|------|---------|----------|
| `modules/lang.zsh` | Locale and encoding (`LANG`, `LC_ALL`) | — |
| `modules/history.zsh` | Large history file and session limits | — |
| `modules/brew.zsh` | Homebrew shell environment | Homebrew |
| `modules/zsh-plugins.zsh` | Syntax highlighting and autosuggestions | zsh plugins (see below) |
| `modules/fzf.zsh` | Fzf defaults and git branch fuzzy finder | `fzf` |
| `modules/direnv.zsh` | Per-directory environment via `.envrc` | `direnv` |
| `modules/git.zsh` | Git aliases (`gb`, `gco`, `gbsync`) and `GIT_ASKPASS` | `git`, `fzf`, `~/.git-askpass` |
| `modules/prompt.zsh` | Colored prompt with directory, git branch, and dirty indicator | — |
| `modules/docker.zsh` | Docker disk usage and prune aliases | Docker |
| `modules/maven.zsh` | `mvn` wrapper that prefers `./mvnw` | Maven (optional) |
| `modules/wordpress.zsh` | `create_wordpress_post` helper | `curl` |
| `modules/macos.zsh` | macOS-only maintenance aliases | macOS |
| `modules/chrome.zsh` | Open Google Chrome | macOS |
| `modules/sdkman.zsh` | SDKMAN init (must load last) | [SDKMAN](https://sdkman.io/install) |

### Git aliases (from `modules/git.zsh`)

- `gb` — fuzzy list branches
- `gco` — fuzzy checkout branch
- `gbsync` — prune local branches deleted on remote

### Fzf git helpers (from `modules/fzf.zsh`)

- `fzf-git-branch` — pick a branch with log preview
- `fzf-git-checkout` — checkout the selected branch
- **Ctrl+R** — fuzzy command history search
- **Ctrl+T** — fuzzy file search
- **Alt+C** — fuzzy cd into directory

### Shell helpers

- `reload-zsh` — reload `~/.zshrc`

## Zsh plugins

`modules/zsh-plugins.zsh` looks for plugins in this order:

1. Homebrew (`/opt/homebrew/share/…` or `/usr/local/share/…`)
2. System packages (`/usr/share/zsh-…` on Debian/Ubuntu)
3. Oh My Zsh custom plugins (`~/.oh-my-zsh/custom/plugins/…`)
4. Cloned plugins in this repo (`plugins/…`, created by `setup.sh`)

Install manually with Homebrew:

```bash
brew install zsh-autosuggestions zsh-syntax-highlighting
```

Or clone into the custom plugin folder:

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
```

## Optional tools

Install these only if you use the matching module:

| Tool | Module | Install |
|------|--------|---------|
| Docker | `modules/docker.zsh` | [docker.com](https://docs.docker.com/get-docker/) |
| SDKMAN | `modules/sdkman.zsh` | `curl -s "https://get.sdkman.io" \| bash` |
| Maven | `modules/maven.zsh` | `brew install maven` or system package |
| `~/.git-askpass` | `modules/git.zsh` | Your own credential helper script |

## Credentials and local overrides

Sensitive or machine-specific files are gitignored:

- `*-credentials.zsh` — secrets (not committed)
- `*-credentials.zsh.tpl` — templates for generating credentials files
- `*-env.zsh` — local environment overrides
- `plugins/` — zsh plugins cloned by `setup.sh`

Create local files alongside the modules they extend, for example `wordpress-credentials.zsh`, and source them from `load.zsh` or your own `~/.zshrc` if needed.

## Manual setup

Without `setup.sh`:

```bash
# Install Oh My Zsh
git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

# Link as Oh My Zsh custom folder
ln -fvs ~/repositories/myzsh-custom ~/.oh-my-zsh/custom

# ~/.zshrc
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true
plugins=(git)
source "$ZSH/oh-my-zsh.sh"
```

Install dependencies for your platform:

```bash
# macOS
brew install git zsh fzf direnv zsh-autosuggestions zsh-syntax-highlighting

# Debian/Ubuntu
sudo apt-get install git zsh fzf direnv
```

## Goals

- Keep configuration modular and easy to maintain
- Share aliases and functions via Git
- Port settings to new machines with `git clone` + `./setup.sh`
- Back up shell customizations in version control
