#!/bin/bash
# Bootstrap a fresh machine: install chezmoi, then init+apply this repo.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/ankurs/dotfiles/chezmoi/bootstrap.sh | bash
# or, after `git clone -b chezmoi`:
#   ./bootstrap.sh
set -eo pipefail

REPO_URL="${DOTFILES_REPO:-git@github.com:ankurs/dotfiles.git}"
BRANCH="${DOTFILES_BRANCH:-chezmoi}"

install_chezmoi() {
    if command -v chezmoi >/dev/null 2>&1; then
        return 0
    fi
    if command -v brew >/dev/null 2>&1; then
        brew install chezmoi
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y chezmoi || \
            sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    else
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    fi
}

install_chezmoi
export PATH="$HOME/.local/bin:$PATH"

# If the user already cloned this repo and is running ./bootstrap.sh from
# inside it, point chezmoi at the local checkout. Otherwise clone fresh.
if [[ -f "$(dirname "$0")/.chezmoiexternal.toml" ]]; then
    chezmoi init --apply --source="$(cd "$(dirname "$0")" && pwd)"
else
    chezmoi init --apply --branch "$BRANCH" "$REPO_URL"
fi
