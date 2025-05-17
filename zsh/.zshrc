# Define $DOTFILES path if not already set
export DOTFILES="$HOME/dotfiles"

# Zinit plugin manager
if [[ ! -f "${HOME}/.zinit/bin/zinit.zsh" ]]; then
  echo "Zinit not found. Please run scripts/install_zsh.sh"
  return
fi

source "${HOME}/.zinit/bin/zinit.zsh"

# Load plugins (lightweight and async)
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light romkatv/powerlevel10k

# Source modular configs
for file in "$DOTFILES/config/zsh/"*.zsh; do
  source "$file"
done
