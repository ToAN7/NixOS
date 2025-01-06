{ config, lib, inputs, username, pkgs, ... }:

{
    imports = [ # Include the results of the hardware scan.
        ./hardware-configuration.nix
        ./tmux.nix
    ];

    # Setup flake permanently
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "${username}"; # Define your hostname.
    networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

    # Set your time zone.
    time.timeZone = "Asia/Ho_Chi_Minh";

    # Select internationalisation properties.
    i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
            LANG = "en_US.UTF-8";
            LC_ADDRESS = "vi_VN";
            LC_IDENTIFICATION = "vi_VN";
            LC_MEASUREMENT = "vi_VN";
            LC_MONETARY = "vi_VN";
            LC_NAME = "vi_VN";
            LC_NUMERIC = "vi_VN";
            LC_PAPER = "vi_VN";
            LC_TELEPHONE = "vi_VN";
            LC_TIME = "vi_VN";
        };

        inputMethod = {
            type = "fcitx5";
            enable = true;

            fcitx5 = {
                waylandFrontend = true;
                addons = with pkgs; [
                    fcitx5-unikey
                    fcitx5-with-addons
                ];
            };
        };

    };
    # console = {
    #   font = "Lat2-Terminus16";
    #   keyMap = "us";
    #   useXkbConfig = true; # use xkb.options in tty.
    # };

    hardware = {
        graphics = {
            enable = true;
            enable32Bit = true;
        };

        nvidia = { 
            modesetting.enable = true;
            open = false;

            nvidiaSettings = true;

            package = config.boot.kernelPackages.nvidiaPackages.stable;
        };
    };

    # Enable the X11 windowing system.
    services.xserver.enable = true;
    services.xserver.videoDrivers = [ "nvidia" "modesetting" ];

    # Enable the KDE Desktop Environment.
    services.displayManager.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;

    # Allow unfree
    nixpkgs.config.allowUnfree = true;
      
    # Configure keymap in X11
    services.xserver.xkb.layout = "us";
    # services.xserver.xkb.options = "eurosign:e,caps:escape";

    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;

        lowLatency = {
            # enable this module
            enable = true;
            # defaults (no need to be set unless modified)
            quantum = 64;
            rate = 48000;
        };
    };

    # make pipewire realtime-capable
    security.rtkit.enable = true;
        security.polkit = {
        enable = true;
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" "docker" "gamemode" ]; # Enable ‘sudo’ for the user.
        packages = with pkgs; [ ];
    };

    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
        # Add any missing dynamic libraries for unpackaged programs
        # here, NOT in environment.systemPackages
        clang-tools
        clang
        llvmPackages_19.libcxx
    ];

    # List packages installed in system profile. To search, run:
    # $ nix search wget
      
    environment.systemPackages = with pkgs; [
        neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        git
        openssh
        libmad

        libGLU
        linuxKernel.packages.linux_xanmod_stable.nvidia_x11
        dotnet-sdk
        wineWowPackages.waylandFull
        cachix

        vulkan-headers 
        vulkan-loader

        wget
        curl
        ripgrep
        gzip
        rar
        gnutar
        unzip
        cargo
        ffmpeg
        fmt
        ninja
        tlp

        cmake
        extra-cmake-modules
        gnumake
        gdb

        luajitPackages.luarocks
        lua51Packages.lua

        go

        python3
        conda

        boost
        libgcc
        gcc14

        docker
        docker-compose

        postgresql

        jdk17
        nodejs_22
        texliveFull
            
        gtk4
    ] ++ [
        wl-clipboard
        waybar
        swappy
        gtk4
        kitty
        mako
        dunst
        grim
        slurp
        swww
        rofi
        lf
        dbus
    ];

    programs.gamemode = {
        enable = true;
    };

    programs.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        xwayland.enable = true;
    };

    programs.neovim = {
        enable = true;
        defaultEditor = true;
    };

    virtualisation.docker = {
        enable = true;
        rootless = {
            enable = true;
            setSocketVariable = true;
        };
    };

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

    # Copy the NixOS configuration file and link it from the resulting system
    # (/run/current-system/configuration.nix). This is useful in case you
    # accidentally delete configuration.nix.
    # system.copySystemConfiguration = true;

    system.stateVersion = "24.05"; # Did you read the comment?

}

