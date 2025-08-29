# Dotfiles

This is my personal development environment that I use daily across different machines. Since all my development happens primarily in the terminal, this setup is very important to me - it's been evolving since 2004 to create an efficient, powerful command-line workflow.

I keep it here primarily to sync my configurations between my macOS and Fedora systems, but I'm sharing it publicly in case others find it useful for learning or inspiration.

It's an opinionated setup that works well for my terminal-centric workflow - your mileage may vary.

## What's Here

This setup includes the tools I use for my terminal-centric development workflow:

- **Shell**: Zsh with Zinit plugin manager - the foundation of terminal-based development
- **Editor**: Neovim configured with AstroNvim - powerful terminal-based editing  
- **Terminal**: tmux with Catppuccin Frappé theme - essential for managing multiple terminal sessions
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
- **Plugin Manager**: Zinit with interactive installation
- **Plugins**: Oh My Zsh plugins for git, docker, kubectl, tmux, brew, and more
- **Modern Aliases**: 
  - `ls` → `eza` (modern ls with icons)
  - `cat` → `bat` (syntax-highlighted cat)
  - `grep` → `rg` (ripgrep for fast searching)
  - `cd` → `zoxide` integration for smart directory jumping
- **Tools**: fzf integration for fuzzy finding files and history
- **Cross-Platform**: Automatic macOS/Fedora detection and PATH configuration

### Editor (Neovim + AstroNvim)
- **Distribution**: AstroNvim for out-of-the-box IDE experience
- **Package Manager**: Lazy.nvim for plugin management
- **LSP Manager**: Mason for language servers, formatters, linters
- **Languages**: Go, Python, JavaScript/TypeScript, Rust, and more

### Terminal (tmux + TPM)
- **Plugin Manager**: TPM (Tmux Plugin Manager)
- **Theme**: Catppuccin Frappé with clean, muted status bar
- **Status Bar**: Displays session info, load averages, CPU usage, battery status, and date/time
- **Session Management**: Automatic session save/restore every 15 minutes
- **Prefix Key**: `Ctrl+a` (instead of default `Ctrl+b`) - see Keyboard Bindings section for all shortcuts
- **Cross-Platform**: Platform-aware clipboard integration

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

### `./check.sh`
Verifies that everything is installed and working correctly on the current system.

### `./update.sh`
Updates all the packages, plugins, and dependencies. I run this periodically to keep everything current.

### `./backup.sh`
Creates timestamped backups of configurations before making changes.

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