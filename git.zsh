#Git configuraiton
export GIT_ASKPASS=~/.git-askpass

#Fetch branches, look for branches that are gone and delete them
alias gbsync='gfa && git gone | xargs git branch -D'
