export GIT_ASKPASS=~/.git-askpass

alias gbsync='gfa && git gone | xargs git branch -D'
alias gb='fzf-git-branch'
alias gco='fzf-git-checkout'

# Thin wrappers around git aliases from repo gitconfig (g <alias>).
# Only aliases that do not clash with different Oh My Zsh meanings.
alias glol='g lol'
alias glola='g lola'
alias gpf='g pf'
alias gdf='g df'
alias gdc='g dc'
alias gunstage='g unstage'
alias gamend='g amend'
alias gundo='g undo'
alias gci='g ci'
