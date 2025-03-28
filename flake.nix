{
    description = "A basic nixos flake of a beginner in linux";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Some others modules
        nix-gaming = {
            url = "github:fufexan/nix-gaming";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        
        # Install Wayland compositor
        hyprland = {
            url = "git+https://github.com/hyprwm/Hyprland";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nix-gaming, nixpkgs, home-manager, hyprland, ... } @ inputs:
    let
        # This is way to install packages in Nix. You import from nixpkgs
        # repostitory and add your system and allow some unfree applications
        # such as Obsidian.
        pkgs = import nixpkgs {
            system = user.info.system;
            config.allowUnfree = true;
        };

        # You will only interact with this once. Set appropirate username,
        # hostname and maybe theme
        user = rec {
            info = {
                # Set your username and hostname
                username = "oslamelon";
                hostname = "oslamelon";

                # You can choose your own theme. I just have two theme:
                # "anby": a ZZZ character because I think her cool :)
                # "default": I don't know how to name it (WIP)
                theme = "anby";

                # This is just your customize stateVersion and system type
                # You can put system = pkgs.system if you know what you are
                # doing
                system = "x86_64-linux";
                stateVersion = "24.05";
            };

            location = {
                home = builtins.toPath "/home/${info.username}";
                config = builtins.toPath "${location.home}/.dotFiles";
            };
        };
    in {
        nixosConfigurations = {
            ${user.info.username} = nixpkgs.lib.nixosSystem {
                specialArgs = {  inherit inputs user;  };
                modules = [ 
                    (./. + "/hosts/${user.info.username}")

                    nix-gaming.nixosModules.pipewireLowLatency

                    {
                        nix.settings = {
                            substituters = [ "https://nix-gaming.cachix.org" ];
                            trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
                        };
                    }

                ];
            };
        };
        homeConfigurations = {
            ${user.info.username} = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                extraSpecialArgs = {  inherit inputs user;  };
                modules = [  
                    hyprland.homeManagerModules.default

                    (./. + "/hosts/${user.info.username}/home.nix")
                ];
            };
        };
        # Making develop shell
        devShells.${user.info.system} = {
            # You can run default Shell by using:
            # nix develop
            default = ( import ./dev/clang.nix {inherit pkgs user;} );

            # Or you can run custom Shell by using:
            # nix develop #shellName
            clang = ( import ./dev/clang.nix {inherit pkgs user;} );
            dotnet = ( import ./dev/dotnet.nix {inherit pkgs user;} );
        };
    };
}
