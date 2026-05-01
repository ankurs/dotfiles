#!/bin/bash
# Bootstrap a fresh machine: install chezmoi (if missing), then init+apply
# this repo as the chezmoi source dir. Run from inside a clone of this repo:
#   git clone -b chezmoi git@github.com:ankurs/dotfiles.git ~/code/dotfiles
#   cd ~/code/dotfiles && ./bootstrap.sh
#
# For zero-clone install (no bootstrap.sh needed):
#   sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --branch chezmoi ankurs/dotfiles
set -eo pipefail

install_chezmoi() {
    if command -v chezmoi >/dev/null 2>&1; then
        return 0
    fi
    if command -v brew >/dev/null 2>&1; then
        brew install chezmoi
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y chezmoi
    else
        echo "Install chezmoi manually for your platform: https://www.chezmoi.io/install/" >&2
        exit 1
    fi
}

install_chezmoi
export PATH="$HOME/.local/bin:$PATH"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
chezmoi init --apply --source="$REPO_DIR"
