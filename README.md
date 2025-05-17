# neox5 Dotfiles

Welcome to my personal dotfiles — structured, minimal, and modular.

These dotfiles are designed for portability, clarity, and ease of management across environments. Everything is grouped into modules that can be individually installed, uninstalled, and queried.

---

## 📦 What's Included

| Module | Description                        | Status     |
|--------|------------------------------------|------------|
| `zsh`  | Shell configuration with Powerlevel10k | ✅ Complete |

---

## 🚀 How to Install

```bash
# Install all modules
./scripts/install.sh

# Install a specific module (e.g., zsh)
./scripts/install.sh zsh
```

---

## 🧹 How to Uninstall

```bash
# Uninstall all modules
./scripts/uninstall.sh

# Uninstall a specific module (e.g., zsh)
./scripts/uninstall.sh zsh
```

---

## 🧩 Module System

Each module in this dotfiles setup is structured to support clean, independent installation and removal.

### General Structure

```plaintext
./<module>/                # Files managed via stow (required)
config/<module>/           # Optional additional configuration
scripts/<module>_install   # Required install script
scripts/<module>_uninstall # Required uninstall script
scripts/<module>_status    # Required status script
```

### Example: `zsh` Module

- `./zsh/` – contains `.zshrc` and related dotfiles, symlinked via `stow`
- `config/zsh/` – optional, used for additional configuration
- `scripts/zsh_install`, `scripts/zsh_uninstall`, `scripts/zsh_status` – lifecycle management scripts

### Script Responsibilities

| Script                  | Role                                                            |
|------------------------|------------------------------------------------------------------|
| `scripts/install.sh`   | Calls `<module>_install`                                         |
| `scripts/uninstall.sh` | Calls `<module>_uninstall`                                       |
| `scripts/status.sh`    | Calls `<module>_status`; handles all output formatting centrally |
| `<module>_status`      | Must **only return a status code**, with **no direct output**    |

### Status Code Contract

- `0` → installed / active
- `1` → not installed / missing
- `2+` → error or invalid state

This contract allows the umbrella `status.sh` script to manage and display results consistently across all modules.
