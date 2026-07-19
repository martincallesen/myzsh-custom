# Debian/Ubuntu ships the binary as batcat (name conflict with another package).
if (( $+commands[batcat] )) && ! (( $+commands[bat] )); then
  alias bat=batcat
fi
