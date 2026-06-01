{ config, pkgs, ... }:

let
    sddmAstronautTheme = pkgs.sddm-astronaut.override {
      embeddedTheme = "hyprland_kath";
    };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.taihim = {
    isNormalUser = true;
    description = "Taimur Ibrahim";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d"; # Automatically wipes generations older than a week
  };

  # Limit the total number of boot entries shown in the menu
  boot.loader.systemd-boot.configurationLimit = 3;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    ghostty
    rofi
    waybar
    google-chrome
    spotify
    vesktop
    nodejs
    git
    bubblewrap
    gcc
    gnumake
    python3
    uv 
    vscode
    btop
    lazydocker
    
    kdePackages.dolphin
    kdePackages.kio-extras
    kdePackages.breeze-icons
    kdePackages.okular
    curl
    
    sddmAstronautTheme
    
    blueman
    pamixer
    pavucontrol
  ];

  virtualisation.docker.enable = true;

  system.stateVersion = "25.11";
  
  programs.hyprland.enable = true;
  
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  }; 

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = [ sddmAstronautTheme ];
    settings.General.InputMethod = "qtvirtualkeyboard";
  };
  
  # Enable Bluetooth hardware support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; # Automatically power up the Bluetooth controller on boot
    settings = {
      General = {
        Experimental = true; # Enables battery percentage reporting for headphones/mice
      };
    };
  };

  # Enable the Bluetooth background system service
  services.blueman.enable = true;


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
      amdgpuBusId = "PCI:4:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
 
  home-manager.users.taihim = { pkgs, ... }: {    
    home.stateVersion = "25.11"; 

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

    # User-level utilities    
    home.packages = with pkgs; [
      fastfetch
    ];    
    
    programs.home-manager.enable = true;
    
    # =========================================================================
    # NATIVE HYPRLAND CONFIGURATION VIA HOME MANAGER
    # =========================================================================
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true; # Ensures older apps run perfectly on Wayland

      # Your actual Hyprland settings written in pure Nix syntax
      settings = {
        "$mainMod" = "SUPER";

        # Monitor layout (Automatically configures your laptop panel)
        monitor = [ ",preferred,auto,1" ];

        #workspace = [
        # "1,monitor:DP-1,default:true"
        # "2,monitor:DP-1"
        # "3,monitor:DP-1"
        # "4,monitor:DP-1"
        # "5,monitor:DP-1"
        # "6,monitor:DP-1"
        # "7,monitor:DP-1"
        # "8,monitor:eDP-1,default:true"
        # "9,monitor:eDP-1"
        #];

        # Startup Applications (Executes once when you log in)
        exec-once = [
          "waybar"
          "blueman-applet"
        ];

        # Core Look & Feel
        general = {
          gaps_in = 6;
          gaps_out = 12;
          "border_size" = 2;
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

        # Nvidia-specific Environment Flags (Critical for your RTX 3060)
        env = [
          "XDG_SESSION_TYPE,wayland"
        ];
      

        animations = {
          enabled = true;

          # Define a natural, fast bezier curve
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

          # Format: animation = [ "element, toggle(1/0), speed, curve, style" ]
          animation = [
            "windows, 1, 3, myBezier, slide"       # Changed speed to 3 (very fast)
            "windowsOut, 1, 3, myBezier, slide"
            "border, 1, 5, default"
            "fade, 1, 3, default"
            "workspaces, 1, 4, myBezier, slide"    # Sliding between workspaces takes 4 frames
          ];
        };


        cursor = {
          "no_hardware_cursors" = true;
        };

        # Your Keyboard Shortcuts Map
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
          "$mainMod M, M, exit" #logout
          "$mainMod, Return, exec, ghostty -e btop"

          # Window Focus Movement (Vim keys)
          "$mainMod, h, movefocus, l"
          "$mainMod, l, movefocus, r"
          "$mainMod, k, movefocus, u"
          "$mainMod, j, movefocus, d"

          # Switch Workspaces
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"


          # Move Active Window to Workspace
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

        # Repeating hardware shortcuts (Volume keys using pamixer)
        bindel = [
          ", XF86AudioRaiseVolume, exec, pamixer -i 5"
          ", XF86AudioLowerVolume, exec, pamixer -d 5"
        ];

        # Locked screen hardware shortcuts (Mute buttons)
        bindl = [
          ", XF86AudioMute, exec, pamixer -t"
          ", XF86AudioMicMute, exec, pamixer --default-source -t"
        ];
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
        window-decoration = false;     # Changed from window-decorations to window-decoration
      };
    };
  }; 
}
