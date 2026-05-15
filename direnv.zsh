# Direnv integration for Zsh
# Direnv is a tool that manages environment variables per directory
# It loads a .envrc file when entering a directory and unloads it when leaving
# This enables automatic activation of project-specific environment variables,
# PATH modifications, and tool versions without manual setup

# Initialize direnv hook into the Zsh shell
# This allows direnv to intercept cd commands and manage environment state
eval "$(direnv hook zsh)"