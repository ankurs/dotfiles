#!/bin/bash
set -eo pipefail

if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    echo "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

if [[ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
    "$HOME/.tmux/plugins/tpm/bin/install_plugins" || true
fi
