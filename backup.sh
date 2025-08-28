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

# Configuration
BACKUP_DIR="$HOME/.dotfiles-backup"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="dotfiles_backup_$DATE"
FULL_BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

# Files and directories to backup
DOTFILES=(
    ".profile"
    ".zshrc"
    ".vimrc"
    ".tmux.conf"
    ".tmux-powerlinerc"
    ".mostrc"
    ".gitconfig"
    ".gitignore"
    ".todo.cfg"
)

DIRECTORIES=(
    ".ssh"
    ".gnupg"
    ".config/nvim"
    ".vim"
    ".tmux/plugins"
    ".local/share/zinit"
    ".cargo"
)

# Optional: backup package lists
backup_package_lists() {
    local backup_path="$1"
    
    if command -v brew &> /dev/null; then
        log_info "Backing up Homebrew packages"
        brew list > "$backup_path/brew_installed_packages.txt" 2>/dev/null || true
        brew list --cask > "$backup_path/brew_installed_casks.txt" 2>/dev/null || true
        brew tap > "$backup_path/brew_taps.txt" 2>/dev/null || true
    fi
    
    if command -v dnf &> /dev/null; then
        log_info "Backing up DNF packages"
        dnf list installed > "$backup_path/dnf_installed_packages.txt" 2>/dev/null || true
    fi
    
    if command -v apt &> /dev/null; then
        log_info "Backing up APT packages"
        apt list --installed > "$backup_path/apt_installed_packages.txt" 2>/dev/null || true
    fi
    
    if command -v npm &> /dev/null; then
        log_info "Backing up global npm packages"
        npm list -g --depth=0 > "$backup_path/npm_global_packages.txt" 2>/dev/null || true
    fi
    
    
    if command -v cargo &> /dev/null; then
        log_info "Backing up Cargo packages"
        cargo install --list > "$backup_path/cargo_packages.txt" 2>/dev/null || true
    fi
}

# Create backup directory
mkdir -p "$BACKUP_DIR"
mkdir -p "$FULL_BACKUP_PATH"

log_info "Creating backup: $BACKUP_NAME"
log_info "Backup location: $FULL_BACKUP_PATH"

# Backup dotfiles
log_info "Backing up dotfiles..."
for file in "${DOTFILES[@]}"; do
    if [[ -f "$HOME/$file" ]]; then
        cp "$HOME/$file" "$FULL_BACKUP_PATH/" && log_success "Backed up $file" || log_warning "Failed to backup $file"
    else
        log_info "$file does not exist, skipping"
    fi
done

# Backup directories
log_info "Backing up directories..."
for dir in "${DIRECTORIES[@]}"; do
    if [[ -d "$HOME/$dir" ]]; then
        mkdir -p "$FULL_BACKUP_PATH/$(dirname "$dir")"
        if cp -r "$HOME/$dir" "$FULL_BACKUP_PATH/$dir"; then
            log_success "Backed up $dir"
        else
            log_warning "Failed to backup $dir"
        fi
    else
        log_info "$dir does not exist, skipping"
    fi
done

# Backup current dotfiles repository state if we're in one
if git rev-parse --git-dir > /dev/null 2>&1; then
    log_info "Backing up git repository state"
    git status > "$FULL_BACKUP_PATH/git_status.txt" 2>/dev/null || true
    git log --oneline -10 > "$FULL_BACKUP_PATH/git_recent_commits.txt" 2>/dev/null || true
    git diff > "$FULL_BACKUP_PATH/git_diff.txt" 2>/dev/null || true
    git stash list > "$FULL_BACKUP_PATH/git_stash.txt" 2>/dev/null || true
fi

# Backup package lists
backup_package_lists "$FULL_BACKUP_PATH"

# Create a manifest of what was backed up
log_info "Creating backup manifest"
cat > "$FULL_BACKUP_PATH/BACKUP_MANIFEST.txt" << EOF
Dotfiles Backup Manifest
========================
Created: $(date)
Hostname: $(hostname)
User: $(whoami)
Platform: $(uname -a)
Backup Path: $FULL_BACKUP_PATH

Files Backed Up:
$(find "$FULL_BACKUP_PATH" -type f | sort)

Directories Backed Up:
$(find "$FULL_BACKUP_PATH" -type d | sort)

Backup Size:
$(du -sh "$FULL_BACKUP_PATH" | cut -f1)
EOF

# Create archive (optional)
if command -v tar &> /dev/null; then
    log_info "Creating compressed archive"
    if tar -czf "$BACKUP_DIR/${BACKUP_NAME}.tar.gz" -C "$BACKUP_DIR" "$BACKUP_NAME"; then
        log_success "Archive created: ${BACKUP_NAME}.tar.gz"
        
        # Ask if user wants to remove the uncompressed backup
        read -p "Remove uncompressed backup directory? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$FULL_BACKUP_PATH"
            log_success "Uncompressed backup removed"
        fi
    else
        log_warning "Failed to create archive"
    fi
fi

# Clean old backups (keep last 10)
log_info "Cleaning old backups (keeping last 10)..."
cd "$BACKUP_DIR"
ls -t | grep "^dotfiles_backup_" | tail -n +11 | while read old_backup; do
    if [[ -d "$old_backup" ]]; then
        rm -rf "$old_backup" && log_info "Removed old backup: $old_backup"
    elif [[ -f "$old_backup" ]]; then
        rm -f "$old_backup" && log_info "Removed old backup: $old_backup"
    fi
done

log_success "Backup completed successfully!"
log_info "Backup location: $FULL_BACKUP_PATH"
log_info "To restore from this backup, see the BACKUP_MANIFEST.txt file"

# Show backup directory contents
log_info "\nCurrent backups:"
ls -la "$BACKUP_DIR" | tail -n +2