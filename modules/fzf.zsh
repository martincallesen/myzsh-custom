# Fzf (Fuzzy Finder) configuration and git integration
# Fzf is a fast, general-purpose command-line fuzzy finder
# This file configures fzf defaults and provides convenient git branch selection utilities

# Default fzf options
# --height 40%: Display fzf in 40% of terminal height
# --layout=reverse: Display input and results with input at the bottom
# --border: Add a border around the fzf window
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Interactive fuzzy finder for git branches
# Lists all local and remote branches sorted by most recent commit
# Shows git log preview for selected branch
# Returns the selected branch name (without remote prefix if applicable)
fzf-git-branch() {
    if ! git rev-parse HEAD > /dev/null 2>&1; then
        echo "Not in a git repository." >&2
        return 1
    fi

    # List all branches with color, sorted by commit date (most recent first)
    # Exclude HEAD and use fzf with preview of recent commits
    git branch --color=always --all --sort=-committerdate |
        grep -v HEAD |
        fzf --height 50% --ansi --no-multi --preview-window right:65% \
            --preview 'git log -n 50 --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed "s/.* //" <<< {})' |
        sed "s/.* //"
}

# Interactive checkout using fzf to select a branch
# Automatically tracks remote branches and checks out local branches
# Usage: fzf-git-checkout
fzf-git-checkout() {
    if ! git rev-parse HEAD > /dev/null 2>&1; then
        echo "Not in a git repository." >&2
        return 1
    fi

    local branch

    # Get branch selection from fzf-git-branch
    branch=$(fzf-git-branch)
    if [[ "$branch" = "" ]]; then
        echo "No branch selected."
        return
    fi

    # If branch name starts with 'remotes/' then it is a remote branch. By
    # using --track and a remote branch name, it is the same as:
    # git checkout -b branchName --track origin/branchName
    if [[ "$branch" = 'remotes/'* ]]; then
        git checkout --track $branch
    else
        git checkout $branch;
    fi
}

# Optional: Disable fzf auto-completion
# Uncomment the following line to disable fuzzy completion for commands and paths
# export DISABLE_FZF_AUTO_COMPLETION="true"

# Fzf key bindings (unless disabled):
# CTRL-T: fuzzy find files and directories
# CTRL-R: fuzzy search command history
# ALT-C: fuzzy find and cd into directory
if [[ -z "${DISABLE_FZF_KEY_BINDINGS:-}" ]]; then
    myzsh_source_plugin \
        /opt/homebrew/opt/fzf/shell/key-bindings.zsh \
        /usr/local/opt/fzf/shell/key-bindings.zsh \
        /usr/share/doc/fzf/examples/key-bindings.zsh
fi
