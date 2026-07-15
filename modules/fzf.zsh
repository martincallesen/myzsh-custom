export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

fzf-git-branch() {
    if ! git rev-parse HEAD > /dev/null 2>&1; then
        echo "Not in a git repository." >&2
        return 1
    fi

    git branch --color=always --all --sort=-committerdate |
        grep -v HEAD |
        fzf --height 50% --ansi --no-multi --preview-window right:65% \
            --preview 'git log -n 50 --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed "s/.* //" <<< {})' |
        sed "s/.* //"
}

fzf-git-checkout() {
    if ! git rev-parse HEAD > /dev/null 2>&1; then
        echo "Not in a git repository." >&2
        return 1
    fi

    local branch

    branch=$(fzf-git-branch)
    if [[ "$branch" = "" ]]; then
        echo "No branch selected."
        return
    fi

    if [[ "$branch" = 'remotes/'* ]]; then
        git checkout --track $branch
    else
        git checkout $branch;
    fi
}

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
