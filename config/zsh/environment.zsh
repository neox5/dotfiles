export EDITOR="nvim"
export PATH="$HOME/bin:$PATH"

# Go environment
export GOPATH="$HOME/go"
export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"

# pyenv setup
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Rust environment
export CARGO="$HOME/.cargo"
export PATH="$CARGO/bin:$PATH"

# Node Version Manager
source /usr/share/nvm/init-nvm.sh

# Bun environment
export BUN="$HOME/.bun"
export PATH="$BUN/bin:$PATH"

# bun completions
[ -s "/home/neox5/.bun/_bun" ] && source "/home/neox5/.bun/_bun"
