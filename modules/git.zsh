export GIT_ASKPASS=~/.git-askpass

alias gbsync='gfa && git gone | xargs git branch -D'
alias gb='fzf-git-branch'
alias gco='fzf-git-checkout'
# Uses git alias `pf` from repo gitconfig (push --force-with-lease)
alias gpf='g pf'
