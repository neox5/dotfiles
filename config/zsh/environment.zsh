export EDITOR="nvim"
export PATH="$HOME/bin:$PATH"
export LC_ALL=C

# Go environment
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# pyenv setup
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
