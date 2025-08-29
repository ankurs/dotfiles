#!/bin/bash
set -eo pipefail

# Terminal colors for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Platform detection
is_macos() { [[ "$OSTYPE" == darwin* ]]; }
is_linux() { [[ "$OSTYPE" == linux* ]]; }
has_cmd() { command -v "$1" &> /dev/null; }

check_cmd() {
    if has_cmd "$1"; then
        log_success "$1 is available"
        return 0
    else
        log_error "$1 is not available"
        return 1
    fi
}

check_file() {
    if [[ -f "$1" ]]; then
        log_success "$1 exists"
        return 0
    else
        log_error "$1 does not exist"
        return 1
    fi
}

check_dir() {
    if [[ -d "$1" ]]; then
        log_success "$1 directory exists"
        return 0
    else
        log_error "$1 directory does not exist"
        return 1
    fi
}

check_symlink() {
    if [[ -L "$1" ]]; then
        local target=$(readlink "$1")
        log_success "$1 → $target"
        return 0
    else
        log_error "$1 is not a symlink"
        return 1
    fi
}

log_info "Checking dotfiles setup..."

# Verify essential commands
log_info "Checking essential commands:"
ESSENTIAL_CMDS=("git" "curl" "zsh" "tmux" "vim" "nvim")
for cmd in "${ESSENTIAL_CMDS[@]}"; do
    check_cmd "$cmd"
done

# Verify modern CLI tools
log_info "\nChecking modern CLI tools:"
MODERN_TOOLS=("fzf" "bat" "eza" "rg" "zoxide")
for tool in "${MODERN_TOOLS[@]}"; do
    if has_cmd "$tool"; then
        log_success "$tool is available"
    else
        log_warning "$tool is not available (optional)"
    fi
done

# Verify shell configuration
log_info "\nChecking shell configuration:"
check_symlink "$HOME/.zshrc"

# Verify zsh as default shell
if [[ "$SHELL" == *"zsh"* ]]; then
    log_success "zsh is the default shell"
else
    log_warning "zsh is not the default shell (current: $SHELL)"
    log_info "Run: chsh -s \$(which zsh)"
fi

# Verify Zinit installation
log_info "\nChecking Zinit:"
if check_dir "$HOME/.local/share/zinit"; then
    if [[ -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
        log_success "Zinit is properly installed"
    else
        log_error "Zinit directory exists but zinit.zsh not found"
    fi
fi

# Verify tmux configuration
log_info "\nChecking tmux configuration:"
check_symlink "$HOME/.tmux.conf"
check_dir "$HOME/.tmux/plugins/tpm"

# Verify neovim configuration
log_info "\nChecking neovim configuration:"

# Verify AstroNvim setup
if [[ -f "$HOME/.config/nvim/init.lua" ]]; then
    log_success "AstroNvim configuration exists"
    
    # Verify Lazy.nvim
    if [[ -f "$HOME/.config/nvim/lazy-lock.json" ]]; then
        log_success "Lazy.nvim lockfile found"
    else
        log_warning "Lazy.nvim lockfile not found"
    fi
    
    # Verify Mason configuration
    if [[ -f "$HOME/.config/nvim/lua/plugins/mason.lua" ]]; then
        log_success "Mason configuration exists"
    else
        log_warning "Mason configuration not found"
    fi
else
    log_error "AstroNvim configuration not found at ~/.config/nvim/init.lua"
fi

# Verify git configuration
log_info "\nChecking git configuration:"
check_symlink "$HOME/.gitconfig"
check_symlink "$HOME/.gitignore"

# Verify SSH keys
log_info "\nChecking SSH configuration:"
if check_file "$HOME/.ssh/id_ed25519.pub"; then
    log_info "SSH public key:"
    cat "$HOME/.ssh/id_ed25519.pub"
fi

# Platform-specific checks
if is_macos; then
    log_info "\nChecking macOS-specific setup:"
    check_cmd "brew"
elif is_linux; then
    log_info "\nChecking Linux-specific setup:"
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        log_info "Distribution: $NAME $VERSION"
        if [[ $NAME == "Fedora Linux" ]]; then
            check_cmd "dnf"
        fi
    fi
fi

# Verify PATH configuration
log_info "\nChecking PATH:"
if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
    log_success "$HOME/.local/bin is in PATH"
else
    log_warning "$HOME/.local/bin is not in PATH"
fi

if [[ -n "${GOBIN:-}" ]] && [[ ":$PATH:" == *":$GOBIN:"* ]]; then
    log_success "GOBIN ($GOBIN) is in PATH"
elif [[ -n "${GOBIN:-}" ]]; then
    log_warning "GOBIN ($GOBIN) is not in PATH"
fi

# Verify environment variables
log_info "\nChecking environment variables:"
[[ -n "${EDITOR:-}" ]] && log_success "EDITOR=$EDITOR" || log_warning "EDITOR not set"
[[ -n "${GOPATH:-}" ]] && log_success "GOPATH=$GOPATH" || log_info "GOPATH not set"
[[ -n "${GOBIN:-}" ]] && log_success "GOBIN=$GOBIN" || log_info "GOBIN not set"

# Test shell configuration
log_info "\nTesting shell functionality:"
if zsh -c "source ~/.zshrc && echo 'Shell sources successfully'" 2>/dev/null; then
    log_success "Shell configuration loads without errors"
else
    log_error "Shell configuration has errors"
fi

# Verify git repository status
if git rev-parse --git-dir > /dev/null 2>&1; then
    log_info "\nGit repository status:"
    if [[ -n "$(git status --porcelain)" ]]; then
        log_warning "Repository has uncommitted changes"
        git status --short
    else
        log_success "Repository is clean"
    fi
    
    # Verify git submodules
    if [[ -f .gitmodules ]]; then
        log_info "\nGit submodules status:"
        while IFS= read -r line; do
            if [[ $line =~ path\ =\ (.+) ]]; then
                submodule_path="${BASH_REMATCH[1]}"
                if [[ -d "$submodule_path" ]]; then
                    log_success "$submodule_path is present"
                else
                    log_error "$submodule_path is missing"
                fi
            fi
        done < .gitmodules
        
        # Display submodule status
        log_info "Submodule commit status:"
        git submodule status | while read status_line; do
            if [[ $status_line =~ ^[[:space:]]*([+-]?)([[:alnum:]]+)[[:space:]]+([^[:space:]]+) ]]; then
                status_char="${BASH_REMATCH[1]}"
                commit_hash="${BASH_REMATCH[2]}"
                path="${BASH_REMATCH[3]}"
                
                case "$status_char" in
                    "-") log_warning "$path: not initialized" ;;
                    "+") log_info "$path: newer commits available" ;;
                    "") log_success "$path: up to date" ;;
                    *) log_info "$path: $status_line" ;;
                esac
            fi
        done
    fi
else
    log_warning "Not in a git repository"
fi

log_info "\nDotfiles check completed!"
log_info "Run './update.sh' to update packages and plugins"