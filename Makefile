.PHONY: install stow unstow

install:
	.install.sh

stow:
	stow -t ~ zsh

unstow:
	stow -D zsh
