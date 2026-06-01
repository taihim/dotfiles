# /etc/nixos/configuration.nix

{ config, pkgs, ... }:

let
  sddmAstronautTheme = pkgs.sddm-astronaut.override {
    embeddedTheme = "hyprland_kath";
  };
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
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
   
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # WARNING: Check these via `lspci | grep -E 'VGA|3D'` on the new Legion!
      amdgpuBusId = "PCI:4:0:0";
      nvidiaBusId = "PCI:1:0:0";
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
    vim gcc gnumake git curl btop fastfetch
    
    # Dev & Languages
    nodejs python3 uv vscode lazydocker bubblewrap
    
    # Apps
    google-chrome spotify vesktop
    
    # Desktop & UI
    ghostty rofi waybar sddmAstronautTheme
    kdePackages.dolphin kdePackages.kio-extras 
    kdePackages.breeze-icons kdePackages.okular
    
    # Audio Control
    pamixer pavucontrol blueman
  ];

  virtualisation.docker.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  }; 

  # ===========================================================================
  # 5. DESKTOP ENVIRONMENT (SYSTEM LEVEL)
  # ===========================================================================
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  
  programs.hyprland.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = [ sddmAstronautTheme ];
    settings.General.InputMethod = "qtvirtualkeyboard";
  };

  # ===========================================================================
  # 6. HOME MANAGER (USER LEVEL SETTINGS)
  # ===========================================================================
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
 
  home-manager.users.taihim = { pkgs, ... }: {    
    home.stateVersion = "25.11"; 
    programs.home-manager.enable = true;

    programs.bash = {
      enable = true;
      shellAliases = {
        rebuild = "sudo nixos-rebuild switch";
      };
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = [ "org.kde.okular.desktop" ];
        "x-scheme-handler/discord" = [ "vesktop.desktop" ];
        "text/html" = [ "google-chrome.desktop" ];
        "x-scheme-handler/http" = [ "google-chrome.desktop" ];
        "x-scheme-handler/https" = [ "google-chrome.desktop" ];
        "x-scheme-handler/about" = [ "google-chrome.desktop" ];
        "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
      };
    };

    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        background-opacity = "0.85";
        background-blur = true;
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

        # Auto-detects display. Update with `hyprctl monitors` output later.
        monitor = [ ",preferred,auto,1" ];

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
          "$mainMod, T, exec, ghostty"
          "$mainMod, R, exec, rofi -show drun -show-icons"
          "$mainMod, B, exec, google-chrome-stable"
          "$mainMod, D, exec, vesktop"
          "$mainMod, M, exec, spotify"
          "$mainMod ALT, B, exec, blueman-manager"
          "$mainMod, F, exec, dolphin"
          "$mainMod, Q, killactive"
          "$mainMod M, M, exit"
          "$mainMod, Return, exec, ghostty -e btop"

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
        ];

        bindl = [
          ", XF86AudioMute, exec, pamixer -t"
          ", XF86AudioMicMute, exec, pamixer --default-source -t"
        ];
      };
    };
  }; 
}
