export EDITOR="nvim"
export PATH="$HOME/bin:$PATH"

# Go environment
export GOPATH="$HOME/go"
export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"

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
