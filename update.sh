#!/bin/bash
set -eo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Platform detection
is_macos() { [[ "$OSTYPE" == darwin* ]]; }
is_linux() { [[ "$OSTYPE" == linux* ]]; }
has_cmd() { command -v "$1" &> /dev/null; }

log_info "Starting dotfiles update..."

# Update git repository
if git rev-parse --git-dir > /dev/null 2>&1; then
    log_info "Updating dotfiles repository"
    if git pull; then
        log_success "Repository updated"
    else
        log_warning "Repository update failed"
    fi
    
    # Update git submodules
    if [[ -f .gitmodules ]]; then
        log_info "Updating git submodules"
        if git submodule update --remote; then
            log_success "Submodules updated"
        else
            log_warning "Submodule update failed"
        fi
    fi
else
    log_warning "Not in a git repository"
fi

# Update system packages
if is_macos && has_cmd "brew"; then
    log_info "Updating Homebrew packages"
    if brew update && brew upgrade; then
        log_success "Homebrew packages updated"
    else
        log_warning "Homebrew update failed"
    fi
elif is_linux && has_cmd "dnf"; then
    log_info "Updating DNF packages"
    if sudo dnf upgrade -y; then
        log_success "DNF packages updated"
    else
        log_warning "DNF update failed"
    fi
elif has_cmd "apt"; then
    log_info "Updating APT packages"
    if sudo apt update && sudo apt upgrade -y; then
        log_success "APT packages updated"
    else
        log_warning "APT update failed"
    fi
fi

# Update Zinit and plugins
if [[ -d "$HOME/.local/share/zinit" ]]; then
    log_info "Updating Zinit and plugins"
    if zsh -c "source ~/.zshrc; zinit update --all" 2>/dev/null; then
        log_success "Zinit plugins updated"
    else
        log_warning "Zinit update failed"
    fi
fi

# Update tmux plugins
if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
    log_info "Updating tmux plugins"
    if ~/.tmux/plugins/tpm/bin/update_plugins all; then
        log_success "Tmux plugins updated"
    else
        log_warning "Tmux plugin update failed"
    fi
fi

# Update neovim plugins (Lazy.nvim + Mason)
if has_cmd "nvim"; then
    log_info "Updating Neovim plugins (Lazy.nvim)"
    if nvim --headless "+Lazy! sync" +qa 2>/dev/null; then
        log_success "Neovim plugins updated via Lazy.nvim"
    else
        log_warning "Neovim plugin update failed"
    fi
    
    log_info "Updating Mason packages"
    if nvim --headless "+MasonToolsUpdate" +qa 2>/dev/null; then
        log_success "Mason packages updated"
    else
        log_info "Mason packages will auto-update on next Neovim startup"
    fi
fi

# Update language-specific package managers
if has_cmd "npm"; then
    log_info "Updating global npm packages"
    if npm update -g; then
        log_success "Global npm packages updated"
    else
        log_warning "npm update failed"
    fi
fi


if has_cmd "cargo"; then
    log_info "Updating Rust packages"
    if cargo install-update -a 2>/dev/null; then
        log_success "Rust packages updated"
    else
        log_info "Install cargo-update with: cargo install cargo-update"
    fi
fi

# Update Go tools if GOBIN is set
if [[ -n "${GOBIN:-}" ]] && [[ -d "$GOBIN" ]]; then
    log_info "Go tools directory: $GOBIN"
    log_info "To update Go tools, run: go install -u \$tool@latest"
fi

log_success "Update completed!"
log_info "Run './check.sh' to verify your setup"