# Entry point for myzsh-custom. Sources modules in a stable order.
# sdkman must load last; see modules/sdkman.zsh.
# Loaded automatically by Oh My Zsh when this repo is linked as custom.

if [[ -z "${ZSH_VERSION:-}" ]]; then
  echo "myzsh-custom: load.zsh must be sourced from zsh, not bash." >&2
  echo "Run: zsh -i" >&2
  return 1 2>/dev/null || exit 1
fi

myzsh_repo_dir="${${(%):-%x}:A:h}"
myzsh_modules_dir="$myzsh_repo_dir/modules"

myzsh_source_if_exists() {
  local file="$1"
  [[ -f "$file" ]] && source "$file"
}

myzsh_source_if_exists "$myzsh_modules_dir/lang.zsh"
myzsh_source_if_exists "$myzsh_modules_dir/history.zsh"
myzsh_source_if_exists "$myzsh_modules_dir/brew.zsh"
myzsh_source_if_exists "$myzsh_modules_dir/zsh-plugins.zsh"
myzsh_source_if_exists "$myzsh_modules_dir/fzf.zsh"
myzsh_source_if_exists "$myzsh_modules_dir/direnv.zsh"
myzsh_source_if_exists "$myzsh_modules_dir/git.zsh"
myzsh_source_if_exists "$myzsh_modules_dir/docker.zsh"
myzsh_source_if_exists "$myzsh_modules_dir/maven.zsh"
myzsh_source_if_exists "$myzsh_modules_dir/wordpress.zsh"

if [[ "$(uname -s)" == "Darwin" ]]; then
  myzsh_source_if_exists "$myzsh_modules_dir/macos.zsh"
  myzsh_source_if_exists "$myzsh_modules_dir/chrome.zsh"
fi

myzsh_source_if_exists "$myzsh_modules_dir/sdkman.zsh"

alias reload-zsh='source ~/.zshrc'
