# /etc/nixos/configuration.nix

{ config, pkgs, ... }:

let
  qylockTheme = pkgs.stdenv.mkDerivation {
    pname = "sddm-qylock-theme";
    version = "cde4d11";

    src = pkgs.fetchFromGitHub {
      owner = "taihim";
      repo = "qylock";
      rev = "cde4d11e9e3d385620becdc877a0521e40a55e47";
      hash = "sha256-17kRwrkdfe+hJdChMxove73zNCKcSi0nmSrO8Fh8hz0=";
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/sddm/themes
      cp -r themes/* $out/share/sddm/themes/

      runHook postInstall
    '';
  };

  waybarPowerProfileStatus = pkgs.writeShellScript "waybar-power-profile-status" ''
    profile="$(${pkgs.power-profiles-daemon}/bin/powerprofilesctl get 2>/dev/null || true)"

    case "$profile" in
      performance)
        text="Performance"
        ;;
      balanced)
        text="Balanced"
        ;;
      power-saver)
        text="Power saver"
        ;;
      *)
        text="Power profile"
        profile="unknown"
        ;;
    esac

    printf '{"text":"%s","tooltip":"Power profile: %s","class":"%s"}\n' "$text" "$text" "$profile"
  '';

  waybarPowerProfileToggle = pkgs.writeShellScript "waybar-power-profile-toggle" ''
    current="$(${pkgs.power-profiles-daemon}/bin/powerprofilesctl get 2>/dev/null || true)"

    case "$current" in
      performance)
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
        ;;
      balanced)
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver
        ;;
      power-saver)
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance
        ;;
      *)
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
        ;;
    esac

    ${pkgs.procps}/bin/pkill -RTMIN+8 waybar
  '';
in
{
  imports = [ 
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];

  # ===========================================================================
  # 1. CORE SYSTEM & BOOT
  # ===========================================================================
  system.stateVersion = "25.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d"; 
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  # Legion Wi-Fi Stability Fix (For Realtek cards if applicable)
  boot.extraModprobeConfig = ''
    options rtw89_core disable_aspm=y
    options rtw89_pci disable_aspm=y
  '';

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # ===========================================================================
  # 2. HARDWARE, POWER & AUDIO (LENOVO LEGION)
  # ===========================================================================
  # Native Lenovo Power Profiles (Fn + Q)
  services.power-profiles-daemon.enable = true;

  # Battery health & CPU frequency scaling
  services.tlp = {
    enable = false;
    settings = {
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Graphics & Nvidia
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  
  };

  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
   
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # WARNING: Check these via `lspci | grep -E 'VGA|3D'` on the new Legion!
      amdgpuBusId = "PCI:196:0:0";
      nvidiaBusId = "PCI:195:0:0";
    };
  };

  # Audio (Pipewire)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; 
    settings.General.Experimental = true; # Battery reporting
  };
  services.blueman.enable = true;

  # ===========================================================================
  # 3. USER ACCOUNTS
  # ===========================================================================
  users.users.taihim = {
    isNormalUser = true;
    description = "Taimur Ibrahim";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  # ===========================================================================
  # 4. SYSTEM PACKAGES & SERVICES
  # ===========================================================================
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Core Utilities
    vim clang gnumake git curl btop fastfetch
    stress-ng
    
    # Dev & Languages
    nodejs python3 uv vscode lazydocker bubblewrap opencode
    
    # Apps
    google-chrome spotify vesktop ollama
    
    # Desktop & UI
    ghostty (rofi.override { plugins = [ rofi-calc ]; }) libqalculate waybar qylockTheme
    grim slurp wl-clipboard hypridle brightnessctl wev
    nvtopPackages.full
    nautilus gnome-themes-extra adwaita-icon-theme
    kdePackages.breeze-icons kdePackages.okular
    
    # Audio Control
    pamixer pavucontrol blueman
  ];

  environment.sessionVariables = {
    CC = "clang";
    CXX = "clang++";
    CPP = "clang-cpp";
    LD = "clang++";
  };

  virtualisation.docker.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  }; 

  programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
  };

  # ===========================================================================
  # 5. DESKTOP ENVIRONMENT (SYSTEM LEVEL)
  # ===========================================================================
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  
  programs.hyprland.enable = true;
  programs.ssh.startAgent = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;
    theme = "pixel-dusk-city";
    extraPackages = with pkgs; [
      qylockTheme
      kdePackages.qt5compat
      kdePackages.qtdeclarative
      kdePackages.qtmultimedia
      kdePackages.qtsvg
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
    ];
    settings = {
      General.InputMethod = "";
      X11.DisplayCommand = "${pkgs.writeShellScript "sddm-external-display" ''
        ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --primary --mode 3440x1440 --rate 179.98 --output eDP-1 --off
      ''}";
    };
  };

  # ===========================================================================
  # 6. HOME MANAGER (USER LEVEL SETTINGS)
  # ===========================================================================
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
 
  home-manager.users.taihim = { pkgs, ... }: {    
    home.stateVersion = "25.11"; 
    programs.home-manager.enable = true;

    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
    };

    home.sessionVariables = {
      GTK_THEME = "Adwaita:dark";
    };

    programs.bash = {
      enable = true;
      shellAliases = {
        rebuild = "sudo nixos-rebuild switch";
        codex = "npx @openai/codex";
      };
    };

    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 28;

          modules-left = [
            "hyprland/workspaces"
            "hyprland/window"
          ];

          modules-center = [
            "clock"
          ];

          modules-right = [
            "custom/power-profile"
            "pulseaudio"
            "network"
            "battery"
            "tray"
          ];

          "hyprland/workspaces" = {
            format = "{name}";
            on-click = "activate";
          };

          "hyprland/window" = {
            max-length = 70;
            separate-outputs = true;
          };

          clock = {
            format = "{:%H:%M}";
            tooltip-format = "{:%A, %B %d, %Y}";
          };

          "custom/power-profile" = {
            exec = "${waybarPowerProfileStatus}";
            return-type = "json";
            interval = 10;
            signal = 8;
            on-click = "${waybarPowerProfileToggle}";
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = "muted";
            format-icons = {
              default = [ "vol" ];
            };
          };

          network = {
            format-wifi = "{essid}";
            format-ethernet = "wired";
            format-disconnected = "offline";
          };

          battery = {
            format = "{capacity}%";
            format-charging = "{capacity}% charging";
          };
        };
      };
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = [ "org.kde.okular.desktop" ];
        "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
        "x-scheme-handler/discord" = [ "vesktop.desktop" ];
        "text/html" = [ "google-chrome.desktop" ];
        "x-scheme-handler/http" = [ "google-chrome.desktop" ];
        "x-scheme-handler/https" = [ "google-chrome.desktop" ];
        "x-scheme-handler/about" = [ "google-chrome.desktop" ];
        "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
      };
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          ignore_dbus_inhibit = false;
          ignore_systemd_inhibit = false;
        };

        listener = [
          {
            timeout = 900;
            on-timeout = "hyprctl dispatch dpms off eDP-1";
            on-resume = "hyprctl dispatch dpms on eDP-1";
          }
          {
            timeout = 2700;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        background = "000000";
        background-opacity = "0.85";
        background-blur = false;
        window-padding-x = 12;
        window-padding-y = 12;
        window-decoration = false;
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true; 

      settings = {
        "$mainMod" = "SUPER";

        monitor = [
          "DP-2,3440x1440@179.98,0x0,1"
          "eDP-1,2560x1600@165,3440x0,1.25"
        ];

        workspace = [
          "1,monitor:DP-2,default:true"
          "2,monitor:DP-2"
          "3,monitor:DP-2"
          "4,monitor:DP-2"
          "5,monitor:DP-2"
          "6,monitor:DP-2"
          "7,monitor:DP-2"
          "8,monitor:eDP-1,default:true"
          "9,monitor:eDP-1"
        ];

        exec-once = [
          "waybar"
          "blueman-applet"
        ];

        general = {
          gaps_in = 6;
          gaps_out = 12;
          border_size = 2;
          "col.active_border" = "rgba(2563ebee) rgba(0ea5e9ee) 45deg";
          "col.inactive_border" = "rgba(1e293baa)";
          layout = "dwindle";
        };

        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 5;
            passes = 2;
          };
        };

        env = [ "XDG_SESSION_TYPE,wayland" ];
        cursor = { "no_hardware_cursors" = true; };

        input = {
          touchpad = {
            natural_scroll = true;
          };
        };

        gesture = "3, horizontal, workspace";

        gestures = {
          workspace_swipe_invert = true;
        };

        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 3, myBezier, slide"       
            "windowsOut, 1, 3, myBezier, slide"
            "border, 1, 5, default"
            "fade, 1, 3, default"
            "workspaces, 1, 4, myBezier, slide"    
          ];
        };

        bind = [
          # System Controls
          "$mainMod, Q, exec, ghostty"
          "$mainMod, R, exec, rofi -show drun -show-icons"
          "$mainMod SHIFT, R, exec, rofi -show calc -modes calc -no-show-match -no-sort -automatic-save-to-history"
          "$mainMod, B, exec, google-chrome-stable"
          "$mainMod, D, exec, vesktop"
          "$mainMod, M, exec, spotify"
          "$mainMod, N, exec, code --ozone-platform=wayland"
          "$mainMod ALT, B, exec, blueman-manager"
          "$mainMod, F, exec, nautilus"
          "$mainMod, C, killactive"
          "$mainMod SHIFT, L, exit"
          "$mainMod SHIFT, P, exec, systemctl poweroff"
          "$mainMod SHIFT, O, exec, systemctl reboot"
          "$mainMod, Return, exec, ghostty -e btop"
          "$mainMod SHIFT, Return, exec, ghostty -e nvtop"
          "$mainMod SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"

          # Focus Movement
          "$mainMod, h, movefocus, l"
          "$mainMod, l, movefocus, r"
          "$mainMod, k, movefocus, u"
          "$mainMod, j, movefocus, d"

          # Workspaces
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"

          # Move to Workspace
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
        ];

        bindel = [
          ", XF86AudioRaiseVolume, exec, pamixer -i 5"
          ", XF86AudioLowerVolume, exec, pamixer -d 5"
          ", XF86MonBrightnessUp, exec, brightnessctl -d amdgpu_bl2 set 5%+"
          ", XF86MonBrightnessDown, exec, brightnessctl -d amdgpu_bl2 set 5%-"
        ];

        bindl = [
          ", XF86AudioMute, exec, pamixer -t"
          ", XF86AudioMicMute, exec, pamixer --default-source -t"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      };
    };
  }; 
}
