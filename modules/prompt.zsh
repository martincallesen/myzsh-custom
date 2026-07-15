# Prompt: current directory, plus git branch when inside a repo.
# Replaces the default hostname-only prompt (e.g. martin-UX32A%).

if [[ -n "${ZSH_THEME:-}" ]]; then
  return 0
fi

autoload -Uz vcs_info

myzsh_git_dirty=''

myzsh_prompt_precmd() {
  myzsh_git_dirty=''

  if command git rev-parse --is-inside-work-tree &>/dev/null; then
    if ! command git diff --no-ext-diff --quiet 2>/dev/null \
       || ! command git diff --cached --quiet 2>/dev/null \
       || [[ -n "$(command git ls-files --others --exclude-standard 2>/dev/null)" ]]; then
      myzsh_git_dirty=' %F{red}●%f'
    fi
  fi

  vcs_info
}

precmd_functions+=(myzsh_prompt_precmd)

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'
zstyle ':vcs_info:git:*' actionformats ' %F{yellow}(%b)%f'

setopt PROMPT_SUBST
PROMPT='%F{cyan}%~%f${vcs_info_msg_0_}${myzsh_git_dirty} %F{green}%# %f'
