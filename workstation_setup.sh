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

log_info "Starting GCP Workstation setup..."

# Verify we're on Debian/Ubuntu
if [[ ! -f /etc/os-release ]]; then
    log_error "Cannot detect OS. This script is for Debian/Ubuntu systems."
    exit 1
fi

source /etc/os-release
if [[ "$ID" != "debian" ]] && [[ "$ID" != "ubuntu" ]]; then
    log_error "This script is for Debian/Ubuntu. Detected: $NAME"
    exit 1
fi

log_info "Detected: $NAME $VERSION"
DOTFILES_DIR=$(pwd)

# Update package lists
log_info "Updating package lists..."
sudo apt-get update

# Install essential packages for neovim
log_info "Installing essential packages..."
sudo apt-get install -y \
    git curl wget zsh tmux \
    neovim \
    python3 python3-pip python3-venv \
    build-essential cmake \
    libssl-dev libffi-dev python3-dev

# Install modern CLI tools
log_info "Installing modern CLI tools..."
sudo apt-get install -y ripgrep fzf bat jq zoxide || log_warning "Some CLI tools unavailable"

# Install language runtimes
log_info "Installing language runtimes..."
sudo apt-get install -y golang-go lua5.3 luajit || log_warning "Some runtimes unavailable"

# Install Node.js via nvm (avoids Ubuntu nodejs/npm conflicts, provides Node 22+ for Codex)
log_info "Installing nvm and Node.js..."
export NVM_DIR="$HOME/.nvm"
if [[ ! -d "$NVM_DIR" ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
# Load nvm for current session
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js 22 LTS (required for OpenAI Codex)
log_info "Installing Node.js 22 LTS..."
nvm install 22
nvm use 22
nvm alias default 22

# Install global npm packages
log_info "Installing npm packages..."
npm install -g neovim || log_warning "npm neovim install failed"

# Install AI coding assistants
log_info "Installing AI coding assistants..."
# Claude Code - https://www.npmjs.com/package/@anthropic-ai/claude-code
npm install -g @anthropic-ai/claude-code || log_warning "Claude Code install failed"
# Gemini CLI - https://www.npmjs.com/package/@google/gemini-cli
npm install -g @google/gemini-cli || log_warning "Gemini CLI install failed"
# OpenAI Codex - https://www.npmjs.com/package/@openai/codex
npm install -g @openai/codex || log_warning "OpenAI Codex install failed"

# Setup Zinit
log_info "Installing Zinit..."
if [[ ! -d "$HOME/.local/share/zinit" ]]; then
    bash -c "$(curl -fsSL https://git.io/zinit-install)" || log_warning "Zinit install failed"
fi

# Setup TPM
log_info "Installing TPM..."
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Create symlinks
log_info "Creating symlinks..."
mkdir -p ~/.cargo/ ~/.config/

ln -sf "$DOTFILES_DIR/dot-zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/dot-tmux.conf" "$HOME/.tmux.conf"
ln -sf "$DOTFILES_DIR/dotgitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES_DIR/dot-gitignore" "$HOME/.gitignore"

# Neovim config
if [[ -d "$HOME/.config/nvim" ]] && [[ ! -L "$HOME/.config/nvim" ]]; then
    log_warning "Backing up existing nvim config to ~/.config/nvim.bak"
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
fi
ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# Sync neovim plugins
log_info "Syncing neovim plugins..."
if command -v nvim &> /dev/null; then
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || log_warning "Plugin sync failed - run manually"
fi

log_success "Workstation setup completed!"
log_info "Start a new shell or run: source ~/.zshrc"
log_info "Open nvim to complete Mason LSP installation"
