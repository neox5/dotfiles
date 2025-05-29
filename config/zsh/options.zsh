# General shell behavior
setopt autocd                    # cd into directories by typing their name
setopt correct                   # suggest corrections for typos
setopt extended_glob             # enable extended globbing patterns

# History configuration
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000           # commands to keep in memory
export SAVEHIST=50000           # commands to save to file

setopt hist_save_no_dups        # ingore duplicates on saving
setopt hist_ignore_space        # ignore commands starting with space
setopt hist_verify              # show command before executing from history
setopt share_history            # share history between all sessions
