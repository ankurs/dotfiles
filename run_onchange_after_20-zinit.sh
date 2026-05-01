#!/bin/bash
set -eo pipefail

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
    echo "Installing Zinit..."
    bash -c "$(curl -fsSL https://git.io/zinit-install)"
fi
