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
│   └── reload-hypr           # Reloads Hyprland config and restarts Waybar
│
├── hypr/                     # Hyprland config (~/.config/hypr/)
│   ├── hyprland.conf         # Main config (keybinds, autostart, window rules)
│   └── monitors.conf         # Monitor layout, refresh rates, scale, workspace assignments
│
├── networkmanager-dmenu/     # (~/.config/networkmanager-dmenu/)
│   └── config.ini            # Sets rofi as the dmenu backend
│
├── rofi/                     # Rofi launcher (~/.config/rofi/)
│   ├── config.rasi           # Main config (modes, font, icons)
│   └── catppuccin-mocha.rasi # Catppuccin Mocha theme (from catppuccin/rofi)
│
├── waybar/                   # Status bar (~/.config/waybar/)
│   ├── config.jsonc          # Module layout and configuration
│   └── style.css             # Catppuccin Mocha styling
│
└── wlogout/                  # Power menu (~/.config/wlogout/)
    ├── layout                # Button layout (lock, suspend, logout, reboot, hibernate, shutdown)
    └── style.css             # Catppuccin Mocha styling
```

---

## Keybinds

| Keybind | Action |
|---|---|
| `SUPER + T` | Open terminal (Alacritty) |
| `SUPER + Q` | Close active window |
| `SUPER + R` | Open app launcher (Rofi) |
| `SUPER + E` | Open file manager |
| `SUPER + V` | Toggle floating |
| `SUPER + SHIFT + R` | Reload Hyprland + Waybar |
| `SUPER + SHIFT + E` | Open power menu (Wlogout) |
| `SUPER + 1–9` | Switch workspace |
| `SUPER + SHIFT + 1–9` | Move window to workspace |
| `SUPER + S` | Toggle scratchpad |
| `SUPER + Arrow keys` | Move focus |

---

## Dependencies

```bash
sudo pacman -S \
  waybar \
  wlogout \
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

| Package | Purpose |
|---|---|
| `waybar` | Status bar |
| `wlogout` | Power menu (lock, suspend, reboot, shutdown) |
| `rofi-wayland` | App launcher and dmenu replacement |
| `networkmanager-dmenu` | NetworkManager frontend via rofi |
| `blueman` | Bluetooth manager (GUI + tray applet) |
| `playerctl` | Media player control (MPRIS waybar module) |
| `wireplumber` | PipeWire session manager |
| `pipewire` | Audio server |
| `asusctl` | ASUS laptop daemon (fan curves, power profiles, ROG features) |
| `supergfxctl` | GPU switching between AMD iGPU and Nvidia dGPU |
| `rog-control-center` | GUI frontend for asusctl |

---

## Waybar Modules

| Module | Left click | Right click | Scroll |
|---|---|---|---|
| Workspaces | Switch to workspace | — | Cycle workspaces |
| Clock | Toggle short/long format | Calendar year view | — |
| Bluetooth | Open Blueman | — | — |
| Volume | Mute/unmute | Audio source/sink picker | Volume ±2% |
| Network | Open networkmanager-dmenu | — | — |
| Power `⏻` | Open Wlogout | — | — |
