# Dotfiles

Modern, cross-platform dotfiles configuration for macOS and Fedora Linux with powerful shell, editor, and terminal setup.

## Features

- **Modern Shell**: Zsh with Zinit plugin manager and Oh My Zsh integration
- **Advanced Editor**: Neovim with AstroNvim, Lazy.nvim, and Mason for LSP/tools
- **Enhanced Terminal**: tmux with TPM (Tmux Plugin Manager) and modern plugins
- **Modern CLI Tools**: fzf, bat, eza, ripgrep, zoxide integration
- **Cross-Platform**: Seamless compatibility between macOS and Fedora
- **Package Management**: Organized package lists with modern developer tools
- **Maintenance Scripts**: Automated backup, update, and health check scripts

## Quick Start

```bash
git clone --recursive https://github.com/ankurs/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
./setup.sh
```

The setup script will:
- Install and configure all dotfiles
- Set up Zinit for zsh plugin management
- Install tmux TPM for plugin management
- Configure Neovim with AstroNvim and modern packages
- Generate SSH keys if needed
- Install platform-specific packages

## Requirements

### macOS
- Homebrew
- Xcode Command Line Tools

### Fedora Linux
- DNF package manager
- Development tools group

### Common Dependencies
- Git
- Zsh (will be set as default shell)
- tmux
- Neovim
- curl

## Configuration Overview

### Shell (Zsh + Zinit)
- **Plugin Manager**: Zinit with interactive installation
- **Plugins**: Oh My Zsh plugins for common tools (git, docker, kubectl, etc.)
- **Modern Tools**: Integrated aliases and functions for bat, eza, fzf, ripgrep
- **Cross-Platform**: Platform-specific detection and configuration

### Editor (Neovim + AstroNvim)
- **Distribution**: AstroNvim for out-of-the-box IDE experience
- **Package Manager**: Lazy.nvim for plugin management
- **LSP Manager**: Mason for language servers, formatters, linters
- **Languages**: Go, Python, JavaScript/TypeScript, Rust, and more

### Terminal (tmux + TPM)
- **Plugin Manager**: TPM (Tmux Plugin Manager)
- **Plugins**: Modern clipboard, session management, and navigation
- **Key Bindings**: Preserved custom mappings
- **Cross-Platform**: Platform-aware clipboard integration

### Modern CLI Tools
- **fzf**: Fuzzy finder for files, history, and commands
- **bat**: Syntax-highlighted cat replacement
- **eza**: Modern ls replacement with icons
- **ripgrep**: Fast recursive search
- **zoxide**: Smart cd replacement with frecency

## Helper Scripts

### `./check.sh`
Comprehensive health check for your dotfiles setup:
- Verifies all tools and dependencies are installed
- Checks symlinks and configuration files
- Validates shell configuration loads correctly
- Reports git repository status

### `./update.sh`
Updates all components of your dotfiles:
- Git repository and submodules
- System packages (brew/dnf)
- Zinit plugins
- tmux plugins
- Neovim packages (Lazy.nvim + Mason)
- Language-specific package managers (npm, cargo)

### `./backup.sh`
Creates timestamped backups of your dotfiles:
- Backs up all configuration files and directories
- Creates package lists for restoration
- Generates compressed archives
- Maintains backup history (keeps last 10)

## Cross-Platform Support

The dotfiles automatically detect the platform and adapt accordingly:

- **Package Management**: Uses brew on macOS, dnf on Fedora
- **Clipboard**: Platform-specific clipboard integration
- **Tools**: Installs appropriate versions for each platform
- **Paths**: Handles different binary locations across platforms

## Package Lists

Organized package lists by category:
- **Development Tools**: Languages, compilers, build tools
- **CLI Utilities**: Modern replacements and productivity tools
- **System Tools**: Process management, networking, monitoring
- **Media**: Image/video processing, converters

## Maintenance

### Regular Updates
```bash
./update.sh  # Update everything
./check.sh   # Verify setup health
```

### Backup Before Changes
```bash
./backup.sh  # Create timestamped backup
```

### Adding New Tools
1. Add to appropriate package list (`brew_list` or `dnf_list`)
2. Run `./update.sh` to install
3. Add configuration as needed

## File Structure

- `dot-*`: Configuration files (automatically symlinked)
- `nvim/`: Neovim configuration with AstroNvim
- `*_list`: Package lists for different package managers
- `setup.sh`: Main installation script
- `check.sh`: Health check script
- `update.sh`: Update all components
- `backup.sh`: Backup configuration
- Submodules: External tools and themes

## License

Personal dotfiles configuration. Feel free to fork and adapt for your own use.