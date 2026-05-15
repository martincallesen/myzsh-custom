# Git configuration and aliases
# Provides git utilities and convenience aliases for common git workflows

# Git credential helper for interactive password/token prompts
# Points to a custom script that handles authentication dialogs
export GIT_ASKPASS=~/.git-askpass

# Alias: gbsync - Synchronize branches by removing deleted remote branches locally
# Fetches all updates from remote and removes local branches that no longer exist upstream
# Usage: gbsync
alias gbsync='gfa && git gone | xargs git branch -D

# Alias: gb - Fuzzy find and display git branches (using fzf integration)
# Provides interactive branch selection with git log preview
# Usage: gb
alias gb='fzf-git-branch'

# Alias: gco - Fuzzy find and checkout git branches interactively
# Automatically handles both local and remote branch tracking
# Usage: gco
alias gco='fzf-git-checkout'
