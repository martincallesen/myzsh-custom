export GIT_ASKPASS=~/.git-askpass

# Official Cursor Agent install puts binaries here (Linux Mint / Linux).
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)

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

# Resolve Cursor Agent CLI (official install or Cursor desktop bundle).
myzsh_cursor_agent() {
  local candidate
  for candidate in agent cursor-agent; do
    if command -v "$candidate" >/dev/null 2>&1; then
      command -v "$candidate"
      return 0
    fi
  done
  candidate="$HOME/.config/Cursor/User/globalStorage/anysphere.cursor-agent-worker/agent-cli/.local/bin/cursor-agent"
  if [[ -x "$candidate" ]]; then
    print -r -- "$candidate"
    return 0
  fi
  return 1
}

# Generate a commit message with Cursor AI for staged changes, then commit.
# Usage: stage files, then run `gcai` (optional git commit args, e.g. gcai --no-verify).
# Requires: Cursor Agent CLI (`curl https://cursor.com/install -fsS | bash`) and `agent login`.
gcai() {
  local agent_bin msg tmp err agent_status
  agent_bin="$(myzsh_cursor_agent)" || {
    print -u2 "gcai: Cursor Agent CLI not found."
    print -u2 "Install: curl https://cursor.com/install -fsS | bash"
    print -u2 "Then:    agent login"
    return 1
  }

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    print -u2 "gcai: not a git repository"
    return 1
  fi

  if git diff --cached --quiet; then
    print -u2 "gcai: nothing staged. Run: git add …"
    return 1
  fi

  print "Generating commit message with Cursor AI…"
  tmp="$(mktemp)" || return 1
  err="$(mktemp)" || { rm -f "$tmp"; return 1; }
  {
    print -r -- "Write a git commit message for the staged changes below."
    print -r -- "Match this repo's recent commit style. Focus on why, not a file list."
    print -r -- "Output ONLY the commit message text — no quotes, markdown fences, or explanation."
    print
    print -r -- "Recent commits:"
    git log -8 --oneline 2>/dev/null || true
    print
    print -r -- "Status:"
    git status --short
    print
    print -r -- "Staged diff:"
    git diff --cached
  } >"$tmp"

  # Feed prompt on stdin (same pattern as Cursor Agent scripting tools).
  msg="$("$agent_bin" -p --trust --mode ask --output-format text <"$tmp" 2>"$err")"
  agent_status=$?
  rm -f "$tmp"

  if (( agent_status != 0 )) \
    || [[ -z "${msg//[$'\t\r\n ']/}" ]] \
    || [[ "${msg:l}" == error:* ]] \
    || [[ "$msg" == *Authentication\ required* ]]; then
    print -u2 "gcai: failed to generate a message"
    [[ -s "$err" ]] && cat "$err" >&2
    [[ -n "$msg" ]] && print -u2 -- "$msg"
    print -u2 "Try: agent login   (or: curl https://cursor.com/install -fsS | bash)"
    rm -f "$err"
    return 1
  fi
  rm -f "$err"

  # Trim leading/trailing whitespace
  msg="${${msg##[[:space:]]#}%%[[:space:]]#}"
  if [[ -z "$msg" ]]; then
    print -u2 "gcai: empty commit message after cleanup"
    return 1
  fi

  print
  print -r -- "$msg"
  print

  if [[ ! -t 0 ]]; then
    git commit -m "$msg" "$@"
    return $?
  fi

  if read -q "?Commit with this message? [y/N] "; then
    print
    git commit -m "$msg" "$@"
  else
    print
    print "Aborted. Message was not committed."
    return 1
  fi
}
