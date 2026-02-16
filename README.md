# Dotfiles

This is my personal development environment that I use daily across different machines. Since all my development happens primarily in the terminal, this setup is very important to me - it's been evolving since 2004 to create an efficient, powerful command-line workflow.

I keep it here primarily to sync my configurations between my macOS and Fedora systems, but I'm sharing it publicly in case others find it useful for learning or inspiration.

It's an opinionated setup that works well for my terminal-centric workflow - your mileage may vary.

## Table of Contents

- [What's Here](#whats-here)
- [Using This Setup](#using-this-setup)
- [Requirements](#requirements)
- [Configuration Overview](#configuration-overview)
- [Keyboard Bindings](#keyboard-bindings)
- [My Utility Scripts](#my-utility-scripts)
- [Cross-Platform Support](#cross-platform-support)
- [Package Lists](#package-lists)
- [Maintenance](#maintenance)
- [File Structure](#file-structure)
- [Common Issues I've Encountered](#common-issues-ive-encountered)
- [Notes](#notes)
- [License](#license)

## What's Here

This setup includes the tools I use for my terminal-centric development workflow:

- **Shell**: Zsh with Zinit plugin manager - the foundation of terminal-based development
- **Editor**: Neovim configured with AstroNvim (OceanicNext theme) - powerful terminal-based editing
- **Terminal Emulator**: Ghostty with Monaco Nerd Font and iTerm2 Dark Background theme
- **Terminal Multiplexer**: tmux with Catppuccin Frappé theme - essential for managing multiple sessions
- **AI Tools**: Claude Code, GitHub Copilot (in Neovim), Gemini CLI, and Codex
- **CLI Tools**: Evolved alternatives that enhance terminal productivity (see CLI Tools Evolution)
- **Scripts**: Personal utilities for maintenance, backups, and health checks
- **Package Lists**: What I install on new systems to recreate this terminal environment

## Using This Setup

This is primarily my personal configuration, but if you want to explore or test it:

```bash
git clone --recursive https://github.com/ankurs/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
./setup.sh
```

**Important**: This is an opinionated setup that will change your shell configuration and install packages. I'd recommend reviewing the code first to see if it aligns with what you want on your system.

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
- **Single Config File**: Consolidated dot-zshrc with optimized loading order
- **Plugin Manager**: Zinit with interactive installation
- **Plugins**: Oh My Zsh plugins for git, docker, kubectl, tmux, brew, and more
- **Modern Aliases**: 
  - `ls` → `eza` (modern ls with icons)
  - `cat` → `bat` (syntax-highlighted cat)
  - `grep` → `rg` (ripgrep for fast searching)
  - `cd` → `zoxide` integration for smart directory jumping
- **Tools**: fzf integration for fuzzy finding files and history
- **Performance**: Lazy loading for NVM, RVM to speed up shell startup
- **Cross-Platform**: Automatic macOS/Fedora detection and PATH configuration

### Editor (Neovim + AstroNvim)
- **Distribution**: AstroNvim for out-of-the-box IDE experience
- **Theme**: OceanicNext colorscheme
- **Package Manager**: Lazy.nvim for plugin management
- **LSP Manager**: Mason for 56+ language servers, formatters, linters, and debuggers
- **Languages**: Go, Python, JavaScript/TypeScript, Rust, and more
- **AI Completion**: GitHub Copilot integration

### Terminal (tmux + TPM)
- **Plugin Manager**: TPM (Tmux Plugin Manager)
- **Theme**: Catppuccin Frappé with clean, muted status bar
- **Status Bar**: Displays session info, load averages, CPU usage, battery status, and date/time
- **Session Management**: Automatic session save/restore every 15 minutes
- **Prefix Key**: `Ctrl+a` (instead of default `Ctrl+b`) - see Keyboard Bindings section for all shortcuts
- **Cross-Platform**: Platform-aware clipboard integration

### Terminal Emulator (Ghostty)
- **Font**: Monaco Nerd Font, size 12
- **Theme**: iTerm2 Dark Background
- **Scrollback**: 10 million lines - I never want to lose output
- **Keybindings**: Uses `Super` key to avoid conflicts with tmux's `Ctrl+a` prefix
- **Splits**: `Cmd+d` (horizontal), `Cmd+Shift+d` (vertical) for quick splitting outside of tmux
- **Shell Integration**: Cursor, sudo, and title detection

### AI Tools
I've been integrating AI tools into my terminal workflow as they've matured:
- **Claude Code**: My primary AI coding assistant, installed via brew cask. Configured with MCP servers for Go (gopls) and Svelte. Settings and plugins live in `claude/`
- **claude-code-templates**: CLI tool for configuring and managing Claude Code templates
- **GitHub Copilot**: Integrated directly into Neovim for inline completions
- **Gemini CLI & Codex**: Installed via Homebrew for quick terminal access

### Git Configuration
- **SSH-first**: All GitHub URLs are rewritten from HTTPS to SSH automatically
- **Default Branch**: `main`
- **Global Gitignore**: Shared ignore rules across all repos
- **Work Config**: Conditional includes for work-specific settings when working with internal repos

### CLI Tools Evolution

Since all my development happens in the terminal, I've been curating command-line tools since 2004. This setup represents that evolution:

- **most** → Pager that replaced `less` - better handling of long output and code files
- **bat** → Syntax-highlighted `cat` - essential for reading code files in terminal
- **eza** → Modern `ls` with icons - evolved through `ls` → `exa` → `eza` for better file browsing  
- **rg** (ripgrep) → Fast recursive search - replaced `grep` and `ack` after years of searching for speed
- **nvim** → Modern vim - evolved from `vi` → `vim` → `neovim` for better plugin ecosystem
- **tmux** → Terminal multiplexing - evolved from `screen` to `tmux` for session management
- **zoxide** → Smart directory jumping - evolved from manual `cd` to various `z` implementations

**Personal Workflow Preferences:**
- **tmuxifier** - session layout management for consistent project setups
- **Custom `code()` function** - searches multiple directories (`~/code/ss/`, `~/code/`, `~/code/jek/`, etc.) to find a project and opens it in tmux. Usage: `code project-name`
- **Cross-platform clipboard** - unified copy/paste commands across macOS and Linux
- **todo.sh** - terminal-based task management

Each tool represents finding better solutions as they became available, while maintaining the terminal-first workflow that's been central to my development process for 20+ years.

## Keyboard Bindings

Here are the key bindings I use daily in this setup:

### tmux (Terminal Multiplexer)

#### Basic Controls
- **Prefix Key**: `Ctrl+a` (instead of default `Ctrl+b`)
- `Ctrl+a` + `r` - Reload configuration file
- `Ctrl+a` + `?` - Show all key bindings

#### Pane Management
- `Ctrl+a` + `|` - Split window horizontally (left/right panes)
- `Ctrl+a` + `-` - Split window vertically (top/bottom panes)
- `Ctrl+a` + `h` - Move to pane on the left
- `Ctrl+a` + `j` - Move to pane below
- `Ctrl+a` + `k` - Move to pane above  
- `Ctrl+a` + `l` - Move to pane on the right
- `Ctrl+a` + `Ctrl+a` - Quick cycle through panes

#### Window Management
- `Ctrl+a` + `c` - Create new window
- `Ctrl+a` + `n` - Next window
- `Ctrl+a` + `p` - Previous window
- `Ctrl+a` + `Ctrl+a` - Switch to last active window
- `Ctrl+a` + `&` - Kill current window

#### Session Management
- `Ctrl+a` + `Ctrl+s` - Save session (tmux-resurrect)
- `Ctrl+a` + `Ctrl+r` - Restore session (tmux-resurrect)
- `Ctrl+a` + `y` - Synchronize input across all panes (ON)
- `Ctrl+a` + `u` - Turn off pane synchronization (OFF)

#### Copy Mode (Vi-style)
- `Ctrl+a` + `[` - Enter copy mode
- `v` - Begin selection (in copy mode)
- `y` - Copy selection to system clipboard
- `Enter` - Copy selection to system clipboard
- `Ctrl+v` - Toggle rectangle/block selection
- `Escape` - Exit copy mode

### Shell (Zsh + Plugins)

#### History & Navigation
- `Ctrl+r` - Reverse history search (incremental)
- `Ctrl+l` - Clear screen
- Up/Down arrows - Navigate through history
- Vi-mode enabled - Use `Esc` then vi commands for editing

#### Modern Tool Shortcuts
- `Ctrl+t` - fzf file finder (when fzf available)
- `Alt+c` - fzf directory navigator (when fzf available)
- `z <partial_name>` - Smart directory jumping with zoxide

#### Plugin-Provided Aliases

**tmux shortcuts** (when tmux plugin loaded):
- `ta` - tmux attach-session
- `ts` - tmux new-session
- `tl` - tmux list-sessions
- `tkss` - tmux kill-session
- `tksv` - tmux kill-server

**Git shortcuts** (from OMZ git plugin):
- `gs` - git status
- `ga` - git add
- `gc` - git commit
- `gp` - git push
- `gl` - git pull
- `gd` - git diff
- `gb` - git branch
- `gco` - git checkout

**Docker shortcuts** (when docker command available):
- `dps` - docker ps
- `dpa` - docker ps -a
- `di` - docker images

**Kubernetes shortcuts** (when kubectl available):
- `k` - kubectl
- `kg` - kubectl get
- `kd` - kubectl describe

### Neovim (AstroNvim + Custom)

#### Leader Keys
- **Leader**: `\` (backslash)
- **Local Leader**: `,` (comma)

#### Custom Mappings
- `<tab>` - Switch between windows
- `<Leader><Leader>` - Switch to last buffer
- `t` - File finder (FzfLua)
- `<Leader>k` - Search word under cursor
- `<Leader>fg` - Live grep
- `]b` / `[b` - Next/previous buffer

#### Test Runner
- `<Leader>tt` - Run nearest test
- `<Leader>tf` - Run test file  
- `<Leader>ts` - Test summary
- `<Leader>to` - Test output
- `<Leader>tr` - Run test
- `<Leader>tS` - Stop test

#### Code Coverage
- `<Leader>cc` - Toggle coverage
- `<Leader>cs` - Coverage summary
- `<Leader>cl` - Load coverage

#### Code Actions
- `<Leader>ca` - Code action (in visual mode)

#### AstroNvim Defaults
For standard AstroNvim keybindings (LSP, file explorer, diagnostics, etc.), see: 
[AstroNvim Mappings Documentation](https://docs.astronvim.com/mappings)

## My Utility Scripts

I've created a few scripts to help maintain this setup across my machines:

### `./setup.sh`
The main installation script. Handles everything from SSH key generation to package installation to symlinking dotfiles. It also supports an update mode (`./setup.sh update`) which updates the repo, submodules, all package managers, plugin managers, and language tools in one go.

### `./check.sh`
My "did I set this up right?" script. It verifies essential commands (git, zsh, tmux, nvim), modern CLI tools (fzf, bat, eza, rg, zoxide), AI tools (claude, gemini, codex), symlink integrity, plugin managers (Zinit, TPM, AstroNvim), SSH keys, git config, and shell configuration loading. I run this after setting up a new machine to make sure nothing was missed.

### `./update.sh`
Updates all the packages, plugins, and dependencies. I run this periodically to keep everything current - it handles brew/dnf, Zinit, TPM, Neovim plugins, Mason tools, npm globals, and cargo packages.

### `./backup.sh`
Creates compressed, timestamped backups to `~/.dotfiles-backup/`. It backs up config files and directories (including SSH keys and cargo config), captures git state (status, diff, stash, recent commits), records installed packages, and generates a manifest. It automatically cleans up old backups, keeping the last 10.

### `./fedora_post_setup.sh`
An interactive menu-driven script I use after a fresh Fedora install. It detects whether I'm on a desktop, laptop, or VM, then lets me selectively install things like browsers, Docker, Kubernetes tools, power management, virtualization, and security hardening (fail2ban).

## Cross-Platform Support

The dotfiles automatically detect the platform and adapt accordingly:

- **Package Management**: Uses brew on macOS, dnf on Fedora
- **Clipboard**: Platform-specific clipboard integration
- **Tools**: Installs appropriate versions for each platform
- **Paths**: Handles different binary locations across platforms

## Package Lists

Organized package lists by category:
- **Development Tools**: Languages (Go, Rust, Python, Node.js), compilers, LSP tools
- **CLI Utilities**: Modern replacements (bat, eza, ripgrep, fzf, zoxide)
- **DevOps & Cloud**: Kubernetes, Docker, Terraform, AWS/GCP tools
- **System Tools**: Process management, networking, monitoring

## Maintenance

### Regular Updates
```bash
./setup.sh update  # Full update: repo, submodules, packages, plugins, language tools
./update.sh        # Update packages, plugins, and dependencies
./check.sh         # Verify setup health
```

### Backup Before Changes
```bash
./backup.sh  # Create timestamped backup
```

### Adding New Tools
1. Add to appropriate package list (`Brewfile` on macOS or `dnf_list` on Fedora)
2. Run `./update.sh` to install
3. Add configuration as needed

## File Structure

### Configuration Files
- `dot-zshrc`: Unified shell configuration (Zsh with all settings)
- `dot-tmux.conf`: tmux configuration
- `dot-ghostty`: Ghostty terminal emulator config
- `dot-mostrc`: `most` pager configuration
- `dot-todo.cfg`: todo.sh task management config
- `dot-gitignore`: Global git ignore rules
- `dotgitconfig`: Git user config, SSH auth, URL rewrites

### Directories
- `nvim/`: Neovim configuration with AstroNvim, Mason, and all plugin configs
- `claude/`: Claude Code settings, MCP server configs, and project instructions
- `fonts/`: Powerline/Nerd fonts (git submodule)
- `fedora/`: Fedora-specific configs (fail2ban, btrbk backups, sysctl tuning, etc.)

### Scripts
- `setup.sh`: Main installation script (also supports `./setup.sh update`)
- `check.sh`: Health check - verifies tools, symlinks, plugins, and configs
- `update.sh`: Update all packages, plugins, and dependencies
- `backup.sh`: Compressed timestamped backups with auto-cleanup
- `fedora_post_setup.sh`: Interactive post-install wizard for Fedora

### Package Lists
- `Brewfile`: macOS Homebrew Bundle file (taps, CLI packages, and GUI casks)
- `dnf_list` / `dnf_remove_list`: Fedora packages to install and remove
- `npm_global_list`: Global npm packages (neovim provider)
- `snap_list`: Snap packages for Fedora
- `cargo-config`: Rust Cargo configuration

## Common Issues I've Encountered

A few things that have tripped me up when setting up on new machines:

**Zinit not installing automatically**
```bash
# Manual installation if needed
git clone https://github.com/zdharma-continuum/zinit.git ~/.local/share/zinit/zinit.git
```

**tmux plugins not loading**
```bash
# Reset TPM if needed
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# In tmux: Ctrl+a + I to install plugins
```

**Shell changes not taking effect**
```bash
# Reload configuration
source ~/.zshrc
```

## Notes

This repository serves as my personal configuration sync between machines and as a public reference for anyone curious about my setup. Feel free to browse through it, copy ideas, or use it as inspiration for your own dotfiles.

The configurations reflect my personal preferences and workflow - they might not work perfectly for everyone, but hopefully they're useful examples of how to set up a modern development environment.

## License

MIT License - feel free to use any part of this configuration.