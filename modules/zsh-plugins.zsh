# Plugins for zsh

myzsh_repo_dir="${${(%):-%x}:A:h}/.."
myzsh_repo_dir="${myzsh_repo_dir:A}"

myzsh_source_plugin() {
  local path
  for path in "$@"; do
    if [[ -f "$path" ]]; then
      source "$path"
      return 0
    fi
  done
  return 1
}

myzsh_source_plugin \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "$myzsh_repo_dir/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

myzsh_source_plugin \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "$myzsh_repo_dir/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
