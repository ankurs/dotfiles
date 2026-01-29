# COSMIC Desktop Configuration

Configuration files for the [COSMIC](https://system76.com/cosmic) desktop environment on Fedora COSMIC Spin.

## Directory Structure

```
cosmic/
├── com.system76.CosmicComp.keybindings/
│   └── v1/
│       └── custom          # Custom keybindings in RON format
└── README.md
```

## Keybindings

Custom keybindings:

| Action | Binding |
|--------|---------|
| Open terminal (alacritty) | Super+Return |
| Close window | Super+Q |
| Lock screen | Super+Alt+L |
| Next wallpaper (variety) | Super+Alt+W |
| Focus left | Super+H |
| Focus down | Super+J |
| Focus up | Super+K |
| Focus right | Super+L |
| Move window left | Super+Shift+H |
| Move window down | Super+Shift+J |
| Move window up | Super+Shift+K |
| Move window right | Super+Shift+L |

## Installation

The `fedora_post_setup.sh` script option 12 (COSMIC Desktop) will:

1. Install variety (wallpaper manager) and alacritty
2. Create `~/.config/cosmic/` directories
3. Symlink custom keybindings
4. Set alacritty as the default terminal via xdg-terminals.list

## RON Format

COSMIC uses the [RON (Rusty Object Notation)](https://github.com/ron-rs/ron) format for configuration files.

## Default COSMIC Keybindings

These defaults work alongside the custom keybindings:

| Action | Binding |
|--------|---------|
| App launcher | Super |
| Workspaces 1-9 | Super+1-9 |
| Toggle maximize | Super+M |
| Toggle floating | Super+G |
| Screenshot | Print |

