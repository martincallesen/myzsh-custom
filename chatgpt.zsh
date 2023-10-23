# Inspired by https://www.howtogeek.com/889200/how-to-run-chatgpt-using-shellgpt-from-the-ubuntu-terminal/
# Github project at https://github.com/TheR1D/shell_gpt
alias chatgpt="cd ~/repositories/github/shellgpt/;source shellgpt/bin/activate"

# Shell-GPT integration ZSH v0.1
_sgpt_zsh() {
if [[ -n "$BUFFER" ]]; then
    _sgpt_prev_cmd=$BUFFER
    BUFFER+="⌛"
    zle -I && zle redisplay
    BUFFER=$(sgpt --shell <<< "$_sgpt_prev_cmd")
    zle end-of-line
fi
}
zle -N _sgpt_zsh
bindkey ^l _sgpt_zsh
# Shell-GPT integration ZSH v0.1
