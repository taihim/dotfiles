# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

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

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
  boot.loader.systemd-boot.configurationLimit = 5; # Keeps your current setup + 4 recent backups

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
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
    
    sddm-astronaut
    
    blueman
    pamixer
    pavucontrol
    asusctl
    supergfxctl
  ];

  virtualisation.docker.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
  
  programs.hyprland.enable = true;
 
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sugar-candy";
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
  
  services.asusd = {
    enable = true;
    enableUserService = true;
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
        monitor = [
          "DP-1,3440x1440@144,0x0,1"
          "eDP-1,2560x1440@120,3440x0,1.6"
        ];

        workspace = [
         "1,monitor:DP-1,default:true"
         "2,monitor:DP-1"
         "3,monitor:DP-1"
         "4,monitor:DP-1"
         "5,monitor:DP-1"
         "6,monitor:DP-1"
         "7,monitor:DP-1"
         "8,monitor:eDP-1,default:true"
         "9,monitor:eDP-1"
        ];

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
          "LIBVA_DRIVER_NAME,nvidia"
          "XDG_SESSION_TYPE,wayland"
          "GBM_BACKEND,nvidia-drm"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
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
          "$mainMod, Q, exec, ghostty"
          "$mainMod, R, exec, rofi -show drun -show-icons"
          "$mainMod, B, exec, google-chrome-stable"
          "$mainMod, D, exec, vesktop"
          "$mainMod, S, exec, spotify"
          "$mainMod ALT, B, exec, blueman-manager"
          "$mainMod, C, killactive"
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

          # Move Active Window to Workspace
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
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
#        theme = "catppuccin-macchiato";
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
