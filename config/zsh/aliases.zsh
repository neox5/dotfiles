alias ll="ls -lah"
alias dotfiles="cd $DOTFILES"
alias nv="nvim"
if command -v nautilus &>/dev/null; then
  alias open="nautilus"
elif command -v dolphin &>/dev/null; then
  alias open="dolphin"
fi
alias clip="xclip -selection clipboard"
alias py="python"
alias ccli="cardano-cli"
