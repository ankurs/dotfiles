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

This branch (`chezmoi`) is managed by [chezmoi](https://www.chezmoi.io/) instead of bash scripts. The `master` branch keeps the older `setup.sh`/`update.sh` workflow if you prefer that.

Fresh machine, end-to-end:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --branch chezmoi ankurs/dotfiles
```

Or, after cloning manually:

```bash
git clone -b chezmoi https://github.com/ankurs/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
./bootstrap.sh
```

On first apply, chezmoi prompts for a few values (git email, todo.txt dir, wallpapers dir, whether to enable work overrides) and stores the answers in `~/.config/chezmoi/chezmoi.toml` per machine.

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
  - `y` → `yazi` wrapper (terminal file manager that syncs directory on exit)
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
- **Pager**: delta for syntax-highlighted, side-by-side diffs with word-level highlighting
- **Merge Conflicts**: zdiff3 style for better conflict resolution
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
- **delta** → Syntax-highlighting git pager - replaced `most` for diffs with word-level highlighting and side-by-side view
- **yazi** → Terminal file manager - async Rust-based file manager with image/PDF preview and zoxide/ripgrep integration

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
- `y` - Launch yazi file manager (changes directory on exit)

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

### `./bootstrap.sh`
One-shot fresh-install entry point: installs chezmoi (via brew/dnf or the official installer fallback), then runs `chezmoi init --apply` against this repo. Subsequent runs from inside the cloned repo apply the local checkout in place.

### Day-to-day chezmoi commands

- `chezmoi update` — pulls the repo and applies changes (replaces the old `update.sh`). The `run_onchange_*` hooks only re-run package installs when the lists actually changed.
- `chezmoi diff` — preview pending changes before applying them.
- `chezmoi edit ~/.zshrc` — edit the source-state version of a managed file; `--apply` reapplies on save.
- `chezmoi add ~/.somerc` — start managing a new file.
- `chezmoi apply` — apply current source state. No-op if nothing changed.

### `./check.sh`
My "did I set this up right?" health-check script. Verifies essential commands, modern CLI tools, AI tools, plugin managers, SSH keys, git config, and shell loading. Lives outside chezmoi's source state — kept around as a standalone utility.

### `./backup.sh`
Creates compressed, timestamped backups to `~/.dotfiles-backup/`. It backs up config files and directories, captures git state, records installed packages, and auto-cleans old backups (keeps last 10).

### `./fedora_post_setup.sh`
Interactive menu-driven script for post-Fedora-install hardware/role-specific setup (browsers, Docker, K8s, power mgmt, fail2ban). Opt-in; not run by `chezmoi apply`.

## Cross-Platform Support

The dotfiles automatically detect the platform and adapt accordingly:

- **Package Management**: Uses brew on macOS, dnf on Fedora
- **Clipboard**: Platform-specific clipboard integration
- **Tools**: Installs appropriate versions for each platform
- **Paths**: Handles different binary locations across platforms

## Package Lists

Organized package lists by category:
- **Development Tools**: Languages (Go, Rust, Python, Node.js), compilers, LSP tools
- **CLI Utilities**: Modern replacements (bat, eza, ripgrep, fzf, zoxide, delta, yazi)
- **DevOps & Cloud**: Kubernetes, Docker, Terraform, AWS/GCP tools
- **System Tools**: Process management, networking, monitoring

## Maintenance

### Regular Updates
```bash
chezmoi update     # git pull + apply (re-runs hooks only for changed inputs)
chezmoi diff       # preview pending changes
./check.sh         # verify setup health
```

### Backup Before Changes
```bash
./backup.sh  # Create timestamped backup
```

### Adding New Tools
1. Add the package to `Brewfile` (macOS) or `dnf_list` (Fedora).
2. Run `chezmoi apply`. The `run_onchange_*` hook for that platform's package manager will detect the file-content change (its hash is embedded in the script template) and re-run only that step. Unchanged steps are no-ops.

### Updating Neovim plugins
`~/.config/nvim/lazy-lock.json` is symlinked (not copied) into the chezmoi source dir, so:
1. In nvim, run `:Lazy sync` to update plugins. Lazy.nvim writes the new pinned SHAs through the symlink straight into the source-state lockfile.
2. From the chezmoi source dir (`chezmoi cd`), `git commit -am "nvim: lockfile bump" && git push`.
3. On other machines, `chezmoi update` pulls the new lockfile and `run_onchange_after_80` runs `:Lazy! restore` to check out the pinned commits.

The same symlink pattern (`run_onchange_after_15-symlink-lockfiles.sh.tmpl`) applies to any other application-modified lockfile you want to track — chezmoi's default copy semantics would otherwise clobber the app's writes on the next apply.

## File Structure

### chezmoi source state (file → target)
- `dot_zshrc.tmpl` → `~/.zshrc` (OS-specific PATH blocks gated at apply-time)
- `dot_tmux.conf` → `~/.tmux.conf`
- `dot_mostrc` → `~/.mostrc`
- `dot_gitconfig.tmpl` → `~/.gitconfig` (templates email + work URL rewrite)
- `dot_gitignore` → `~/.gitignore`
- `dot_todo.cfg.tmpl` → `~/.todo.cfg` (templates `TODO_DIR`)
- `dot_cargo/config.toml` → `~/.cargo/config.toml`
- `dot_config/nvim/` → `~/.config/nvim/`
- `dot_config/variety/variety.conf.tmpl` → `~/.config/variety/variety.conf` (Linux only)
- `dot_config/ghostty/config.tmpl` → `~/.config/ghostty/config` (Linux only; thin wrapper around shared template)
- `private_Library/private_Application Support/com.mitchellh.ghostty/config.tmpl` → `~/Library/Application Support/com.mitchellh.ghostty/config` (macOS only)
- `dot_claude/CLAUDE.md`, `dot_claude/settings.json`, `dot_claude/mcp-global.json.tmpl` → `~/.claude/...`
- `.chezmoitemplates/ghostty.conf` — shared template body for Ghostty config

### chezmoi config files
- `.chezmoi.toml.tmpl` — prompts on first init (email, todo dir, wallpapers dir, work overrides)
- `.chezmoiignore` — repo-root files that aren't dotfiles (Brewfile, scripts, etc.) and OS-gated targets
- `.chezmoiexternal.toml` — pulls the powerline fonts repo into `~/.local/share/fonts/powerline` (replaces the old git submodule)

### Bootstrap and update hooks
- `run_onchange_before_10-ssh-key.sh.tmpl` — generate ed25519 if absent
- `run_onchange_after_20-zinit.sh` — install Zinit if absent
- `run_onchange_after_30-tpm.sh` — install TPM and tmux plugins
- `run_onchange_after_40-fonts.sh.tmpl` — refresh font cache (Linux) / copy to `~/Library/Fonts` (macOS)
- `run_onchange_after_50-default-shell.sh.tmpl` — `chsh -s zsh` on Linux if not already
- `run_onchange_after_70-packages-darwin.sh.tmpl` — `brew bundle install` (re-runs when Brewfile changes)
- `run_onchange_after_71-packages-fedora.sh.tmpl` — copr enable + `dnf install` (re-runs when dnf_list changes)
- `run_onchange_after_72-cargo.sh.tmpl` — install missing cargo packages, then `cargo install-update -a`
- `run_onchange_after_73-npm.sh.tmpl` — `npm i -g --upgrade` from npm_global_list
- `run_onchange_after_80-nvim-update.sh.tmpl` — `nvim --headless +Lazy! sync` (re-runs when lazy-lock.json changes)

All hooks are idempotent and safe to re-run; chezmoi only fires them when their hashed inputs change.

### Standalone scripts (not run by chezmoi)
- `bootstrap.sh` — one-shot fresh-install entry point
- `check.sh` — health check
- `backup.sh` — timestamped backups
- `fedora_post_setup.sh` — interactive Fedora post-install wizard

### Package and config lists
- `Brewfile`, `dnf_list`, `dnf_remove_list`, `cargo_list`, `npm_global_list`, `snap_list` — package manifests, hashed by the `run_onchange_*` hooks
- `fedora/` — Fedora-specific configs (fail2ban, btrbk, sysctl, etc.); applied manually by `fedora_post_setup.sh`

## Common Issues I've Encountered

**Force a hook to re-run**
chezmoi caches script hashes under `~/.config/chezmoi/scriptstate.boltdb`. To rerun a single hook (e.g. after fixing a transient install failure):
```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

**Re-prompt for a template variable**
Edit `~/.config/chezmoi/chezmoi.toml` directly, or:
```bash
chezmoi init  # re-runs prompts; overwrites chezmoi.toml
```

**Shell changes not taking effect**
```bash
source ~/.zshrc
```

## Notes

This repository serves as my personal configuration sync between machines and as a public reference for anyone curious about my setup. Feel free to browse through it, copy ideas, or use it as inspiration for your own dotfiles.

The configurations reflect my personal preferences and workflow - they might not work perfectly for everyone, but hopefully they're useful examples of how to set up a modern development environment.

## License

MIT License - feel free to use any part of this configuration.