# Completion definitions: custom completions live in config/zsh/completions.
# fpath must be extended before compinit runs.
fpath=("$DOTFILES/config/zsh/completions" $fpath)
autoload -Uz compinit && compinit
