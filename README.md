# dotfiles

Collection of dotfiles for quicker setup of PC.

**Distro:** CachyOS
**WM:** Hyprland
**Theme:** Catppuccin Mocha

---

## Directory Structure

```
dotfiles/
├── bin/                      # Custom scripts (~/.local/bin/)
│   ├── audio-picker          # Rofi-based input/output audio source selector (pactl)
│   ├── power-menu            # Rofi-based power menu (lock, suspend, logout, reboot, hibernate, shutdown)
│   └── reload-hypr           # Reloads Hyprland config and restarts Waybar + Walker
│
├── hypr/                     # Hyprland config (~/.config/hypr/)
│   ├── hyprland.conf         # Main config (keybinds, autostart, window rules)
│   └── monitors.conf         # Monitor layout, refresh rates, scale, workspace assignments
│
├── networkmanager-dmenu/     # (~/.config/networkmanager-dmenu/)
│   └── config.ini            # Sets rofi as the dmenu backend
│
├── rofi/                     # Rofi (~/.config/rofi/) — used for dmenu popups, not app launcher
│   ├── config.rasi           # Main config
│   └── Arc-Dark.rasi         # Arc Dark theme
│
├── walker/                   # Walker app launcher (~/.config/walker/)
│   └── config.toml           # Providers, prefixes, keybinds
│
├── elephant/                 # Elephant backend config (~/.config/elephant/)
│   └── websearch.toml        # Web search engine (Google)
│
└── waybar/                   # Status bar (~/.config/waybar/)
    ├── config.jsonc          # Module layout and configuration
    └── style.css             # Catppuccin Mocha styling
```

---

## Keybinds

| Keybind | Action |
|---|---|
| `SUPER + T` | Open terminal (Alacritty) |
| `SUPER + Q` | Close active window |
| `SUPER + R` | Open app launcher (Walker) |
| `SUPER + B` | Open browser (Chrome) |
| `SUPER + E` | Open file manager |
| `SUPER + V` | Toggle floating |
| `SUPER + SHIFT + R` | Reload Hyprland + Waybar + Walker |
| `SUPER + SHIFT + E` | Open power menu |
| `SUPER + Escape` | Open power menu |
| `SUPER + 1–9` | Switch workspace |
| `SUPER + SHIFT + 1–9` | Move window to workspace |
| `SUPER + S` | Toggle scratchpad |
| `SUPER + Arrow keys` | Move focus |

---

## Dependencies

### pacman

```bash
sudo pacman -S \
  waybar \
  rofi-wayland \
  networkmanager-dmenu \
  blueman \
  playerctl \
  wireplumber \
  pipewire \
  asusctl \
  supergfxctl \
  rog-control-center
```

### AUR

```bash
yay -S \
  walker \
  elephant-bin \
  elephant-desktopapplications-bin \
  elephant-websearch-bin \
  elephant-files-bin \
```

| Package | Purpose |
|---|---|
| `waybar` | Status bar |
| `rofi-wayland` | Dmenu replacement (used by audio-picker, networkmanager-dmenu, power-menu) |
| `networkmanager-dmenu` | NetworkManager frontend via rofi |
| `blueman` | Bluetooth manager (GUI + tray applet) |
| `playerctl` | Media player control (MPRIS waybar module) |
| `wireplumber` | PipeWire session manager |
| `pipewire` | Audio server |
| `asusctl` | ASUS laptop daemon (fan curves, power profiles, ROG features) |
| `supergfxctl` | GPU switching between AMD iGPU and Nvidia dGPU |
| `rog-control-center` | GUI frontend for asusctl |
| `walker` | App launcher with provider prefixes |
| `elephant-bin` | Backend service for Walker |
| `elephant-desktopapplications-bin` | Desktop apps provider plugin for elephant |
| `elephant-websearch-bin` | Web search provider plugin for elephant |
| `elephant-files-bin` | File search provider plugin for elephant |

### Post-install: enable elephant service

```bash
elephant service enable
systemctl --user start elephant
```

---

## Walker Prefixes

| Prefix | Provider |
|---|---|
| *(none)* | App search |
| `=` | Calculator |
| `.` | File search |
| `$` | Clipboard |
| `@` | Web search |
| `:` | Symbols |
| `/` | Switch provider |

---

## Waybar Modules

| Module | Left click | Right click | Scroll |
|---|---|---|---|
| Workspaces | Switch to workspace | — | Cycle workspaces |
| Clock | Toggle short/long format | Calendar year view | — |
| Bluetooth | Open Blueman | — | — |
| Volume | Mute/unmute | Audio source/sink picker | Volume ±2% |
| Network | Open networkmanager-dmenu | — | — |
| Power `⏻` | Open power menu | — | — |
