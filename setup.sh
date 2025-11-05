#!/bin/bash
set -eo pipefail

# Terminal colors for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Progress tracking variables
STEPS_TOTAL=0
STEPS_COMPLETED=0

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

progress() {
    STEPS_COMPLETED=$((STEPS_COMPLETED + 1))
    echo -e "${BLUE}[${STEPS_COMPLETED}/${STEPS_TOTAL}]${NC} $1"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "Required command '$1' not found"
        return 1
    fi
}

UPDATE=""
if [[ ! -z "${1:-}" ]]; then
    UPDATE="yes"
    log_info "Update mode enabled"
fi

function setup_mac() {
    log_info "Setting up macOS environment"
    
    # Verify required files exist
    for file in brew_tap brew_list brew_cask_list; do
        if [[ ! -f "./$file" ]]; then
            log_error "Required file $file not found"
            return 1
        fi
    done
    if [[ ! -x $(which brew 2>/dev/null || echo) ]]; then
        progress "Installing Homebrew package manager"
        if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            log_success "Homebrew installed successfully"
        else
            log_error "Failed to install Homebrew"
            return 1
        fi
    else
        log_info "Homebrew already installed"
    fi
    progress "Optimizing system performance"
    if sudo sysctl debug.lowpri_throttle_enabled=0; then
        log_success "Disabled low priority throttling"
    else
        log_warning "Failed to disable low priority throttling (non-critical)"
    fi
    progress "Adding Homebrew taps"
    if cat ./brew_tap | xargs -L 1 brew tap; then
        log_success "Homebrew taps added"
    else
        log_warning "Some taps may have failed to add"
    fi
    
    progress "Installing Homebrew packages"
    if cat ./brew_list | grep -v '^#' | grep -v '^$' | xargs -L 1 brew install; then
        log_success "Homebrew packages installed"
    else
        log_warning "Some packages may have failed to install"
    fi
    
    progress "Installing universal-ctags"
    if brew install --HEAD universal-ctags/universal-ctags/universal-ctags; then
        log_success "Universal-ctags installed"
    else
        log_warning "Universal-ctags installation failed"
    fi
    
    progress "Installing Homebrew cask applications"
    if [[ -f ./brew_cask_list ]] && cat ./brew_cask_list | grep -v '^#' | grep -v '^$' | xargs -L 1 brew install; then
        log_success "Homebrew cask applications installed"
    else
        log_warning "Some cask applications may have failed to install"
    fi
}

function setup_fedora() {
    log_info "Setting up Fedora environment"
    
    # Verify required files exist
    if [[ ! -f "./dnf_list" ]]; then
        log_error "Required file dnf_list not found"
        return 1
    fi
    progress "Configuring DNF for fastest mirrors"
    set +e
    if ! grep -q -F 'fastestmirror=True' /etc/dnf/dnf.conf; then
        if echo 'fastestmirror=True' | sudo tee --append /etc/dnf/dnf.conf; then
            log_success "DNF configured for fastest mirrors"
        else
            log_warning "Failed to configure DNF (non-critical)"
        fi
    else
        log_info "DNF already configured for fastest mirrors"
    fi
    set -e

    if [[ -z $UPDATE ]]; then
        progress "Enabling SSH service"
        if sudo systemctl enable sshd && sudo systemctl start sshd; then
            log_success "SSH service enabled and started"
        else
            log_warning "SSH service setup failed"
        fi
        
        progress "Setting up RPM Fusion repositories"
        if sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm; then
            log_success "RPM Fusion repositories installed"
        else
            log_warning "RPM Fusion setup failed"
        fi
        
        progress "Updating core system packages"
        sudo dnf group upgrade core -y && sudo dnf update-minimal -y
        
        progress "Installing Development Tools"
        if sudo dnf group install "Development Tools" -y; then
            log_success "Development Tools installed"
        else
            log_warning "Development Tools installation failed"
        fi
        
        progress "Installing essential development packages"
        if sudo dnf install -y cmake make python-devel vim neovim zsh gcc-c++; then
            log_success "Essential packages installed"
        else
            log_warning "Some essential packages failed to install"
        fi
        
        progress "Installing and configuring Snap"
        if sudo dnf install -y snapd; then
            sudo ln -sf /var/lib/snapd/snap /snap 2>/dev/null || true
            log_info "Waiting for snap to seed..."
            sudo snap wait system seed.loaded
            log_success "Snap installed and configured"
        else
            log_warning "Snap installation failed"
        fi
        progress "Setting up Google Cloud SDK repository"
        # Determine architecture - uname -i may return "unknown" in VMs
        ARCH=$(uname -m)
        if [[ "$ARCH" == "x86_64" ]]; then
            REPO_ARCH="x86_64"
        elif [[ "$ARCH" == "aarch64" ]]; then
            REPO_ARCH="arm64"
        else
            REPO_ARCH="$ARCH"
        fi
        
        if sudo tee /etc/yum.repos.d/google-cloud-sdk.repo > /dev/null << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-${REPO_ARCH}
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
        then
            log_success "Google Cloud SDK repository configured"
        else
            log_warning "Google Cloud SDK repository setup failed"
        fi
        
        progress "Installing AWS CLI"
        # Use uname -m for architecture as uname -i may return "unknown" in VMs
        if curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" && \
           unzip awscliv2.zip && \
           sudo ./aws/install; then
            log_success "AWS CLI installed"
        else
            log_warning "AWS CLI installation failed"
        fi
        rm -rf aws awscliv2.zip 2>/dev/null || true
    fi

    progress "Upgrading system packages"
    if sudo dnf upgrade -y; then
        log_success "System packages upgraded"
    else
        log_warning "System upgrade failed"
    fi
    
    progress "Installing packages from dnf_list"
    if cat ./dnf_list | grep -v '^#' | grep -v '^$' | xargs -L 20 sudo dnf install -y; then
        log_success "DNF packages installed"
    else
        log_warning "Some DNF packages failed to install"
    fi
    
    if [[ -z $UPDATE ]] && [[ -f "fedora_post_setup.sh" ]]; then
        progress "Running Fedora post-setup script"
        if bash fedora_post_setup.sh; then
            log_success "Post-setup script completed"
        else
            log_warning "Post-setup script failed"
        fi
    fi
}

count_steps() {
    STEPS_TOTAL=8  # SSH key, Zinit, TPM, fonts, symlinks, platform setup, npm, nvim
    
    # Add platform-specific steps
    if [[ $(uname) == "Darwin" ]]; then
        STEPS_TOTAL=$((STEPS_TOTAL + 6))  # brew install, taps, packages, ctags, casks, optimization
    elif [[ $(uname) == "Linux" ]] && [[ -f /etc/os-release ]]; then
        source /etc/os-release
        if [[ $NAME == "Fedora Linux" ]]; then
            STEPS_TOTAL=$((STEPS_TOTAL + 8))  # dnf config, ssh, repos, updates, dev tools, snap, cloud tools, packages
        fi
    fi
    
    if [[ -z $UPDATE ]]; then
        STEPS_TOTAL=$((STEPS_TOTAL + 2))  # fonts and symlinks only in non-update mode
    else
        # In update mode on Linux, add font cache refresh step
        if [[ $(uname) == "Linux" ]]; then
            STEPS_TOTAL=$((STEPS_TOTAL + 1))  # font cache refresh
        fi
    fi
}

function do_setup() {
    local platform=$(uname)
    log_info "Detected platform: $platform"
    
    if [[ $platform == "Darwin" ]]; then
        if ! setup_mac; then
            log_error "macOS setup failed"
            return 1
        fi
    elif [[ $platform == "Linux" ]] && [[ -f /etc/os-release ]]; then
        source /etc/os-release
        if [[ $NAME == "Fedora Linux" ]]; then
            if ! setup_fedora; then
                log_error "Fedora setup failed"
                return 1
            fi
        else
            log_warning "Unsupported Linux distribution: $NAME"
        fi
    else
        log_warning "Unsupported platform: $platform"
    fi
}

# Initialize progress tracking
count_steps
log_info "Starting dotfiles setup (${STEPS_TOTAL} steps)"

# Initialize git submodules if needed
if [[ -f .gitmodules ]]; then
    log_info "Initializing git submodules..."
    if git submodule update --init --recursive; then
        log_success "Git submodules initialized"
    else
        log_warning "Git submodule initialization failed"
    fi
fi

# SSH Key Setup
# Generate Ed25519 key (preferred for security and speed)
# Keep existing RSA key if present for legacy system compatibility
if [[ ! -f $HOME/.ssh/id_ed25519.pub ]]; then
    progress "Generating SSH key (Ed25519)"
    if ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)"; then
        log_success "Ed25519 SSH key generated"
    else
        log_error "SSH key generation failed"
        exit 1
    fi
else
    progress "Ed25519 SSH key already exists"
fi

# Check for legacy RSA key
if [[ -f $HOME/.ssh/id_rsa.pub ]]; then
    log_info "RSA SSH key also present (good for legacy compatibility)"
fi

log_info "Your SSH public key:"
cat $HOME/.ssh/id_ed25519.pub
read -p "Please make sure GitHub is updated with the SSH key of this system [Press Enter to continue]" discard

progress "Installing Zinit (zsh plugin manager)"
if [[ ! -d "$HOME/.local/share/zinit" ]]; then
    if bash -c "$(curl -fsSL https://git.io/zinit-install)"; then
        log_success "Zinit installed"
    else
        log_warning "Zinit installation failed"
    fi
else
    log_info "Zinit already installed"
fi

progress "Installing TPM (tmux plugin manager)"
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    if git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm; then
        log_success "TPM installed"
        # Auto-install tmux plugins
        log_info "Installing tmux plugins..."
        if ~/.tmux/plugins/tpm/bin/install_plugins; then
            log_success "Tmux plugins installed"
        else
            log_warning "Tmux plugin installation failed (manual install needed)"
        fi
    else
        log_warning "TPM installation failed"
    fi
else
    log_info "TPM already installed"
    # Update plugins if TPM exists
    if [[ -x "$HOME/.tmux/plugins/tpm/bin/update_plugins" ]]; then
        log_info "Updating tmux plugins..."
        ~/.tmux/plugins/tpm/bin/update_plugins all
    fi
fi

if [[ -z $UPDATE ]]; then
    progress "Installing fonts"
    if [[ -f "fonts/install.sh" ]] && bash fonts/install.sh; then
        log_success "Fonts installed"
        # Refresh font cache on Linux
        if [[ $(uname) == "Linux" ]] && command -v fc-cache &>/dev/null; then
            log_info "Refreshing font cache..."
            fc-cache -f ~/.local/share/fonts
        fi
    else
        log_warning "Font installation failed or script not found"
    fi
    
    progress "Creating symbolic links"
    PWD=$(pwd)
    
    # Create configuration symlinks
    declare -A dotfiles=(
        ["$PWD/dot-zshrc"]="~/.zshrc"
        ["$PWD/dot-tmux.conf"]="~/.tmux.conf"
        ["$PWD/dot-mostrc"]="~/.mostrc"
        ["$PWD/dotgitconfig"]="~/.gitconfig"
        ["$PWD/dot-gitignore"]="~/.gitignore"
        ["$PWD/dot-todo.cfg"]="~/.todo.cfg"
    )
    
    for src in "${!dotfiles[@]}"; do
        dst="${dotfiles[$src]}"
        expanded_dst="${dst/#~/$HOME}"
        if ln -sf "$src" "$expanded_dst"; then
            log_info "Linked $(basename "$src")"
        else
            log_warning "Failed to link $(basename "$src")"
        fi
    done
    
    # Additional configuration directories
    mkdir -p ~/.cargo/ ~/.config/nvim/
    ln -sf "$PWD/cargo-config" ~/.cargo/config

    # Platform-specific Ghostty configuration
    if [[ $(uname) == "Darwin" ]]; then
        # macOS: Use Application Support directory
        mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
        if ln -sf "$PWD/dot-ghostty" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"; then
            log_info "Linked Ghostty config (macOS)"
        else
            log_warning "Failed to link Ghostty config"
        fi
    else
        # Linux: Use XDG config directory
        mkdir -p ~/.config/ghostty
        if ln -sf "$PWD/dot-ghostty" ~/.config/ghostty/config; then
            log_info "Linked Ghostty config (Linux)"
        else
            log_warning "Failed to link Ghostty config"
        fi
    fi

    # Neovim uses AstroNvim with Lazy.nvim
    log_info "Neovim will use AstroNvim configuration at ~/.config/nvim/"
    log_success "Symbolic links created"
else
    # In update mode, just refresh font cache if on Linux
    if [[ $(uname) == "Linux" ]] && command -v fc-cache &>/dev/null; then
        progress "Refreshing font cache"
        if fc-cache -f ~/.local/share/fonts; then
            log_success "Font cache refreshed"
        else
            log_warning "Font cache refresh failed"
        fi
    fi
    log_info "Update mode: skipping initial setup"
fi

# Execute platform-specific setup
do_setup

progress "Installing Node.js neovim package"
if npm i -g neovim --upgrade 2>/dev/null; then
    log_success "Node.js neovim package installed"
else
    log_warning "Node.js neovim package installation failed (npm may not be available)"
fi


progress "Installing and updating Neovim plugins"
if command -v nvim &> /dev/null; then
    if nvim --headless "+Lazy! sync" +qa 2>/dev/null; then
        log_success "Neovim plugins synced via Lazy.nvim"
    else
        log_warning "Neovim plugin sync failed"
    fi
    
    # Mason packages will auto-install on first Neovim startup
    log_info "Language servers managed by Mason.nvim"
else
    log_warning "Neovim not found, skipping plugin installation"
fi

log_success "\nDotfiles setup completed! (${STEPS_COMPLETED}/${STEPS_TOTAL} steps)"
log_info "Language servers are now managed by Mason.nvim in Neovim config"
log_info "Tmux plugins have been installed. If you're in tmux, reload with: tmux source ~/.tmux.conf"
