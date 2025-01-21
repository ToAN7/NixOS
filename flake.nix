{
    description = "A nixos flake with anby theme";

    inputs = {
        nix-gaming = {
            url = "github:fufexan/nix-gaming";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nvf = {
            url = "github:notashelf/nvf";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        
        hyprland = {
            url = "git+https://github.com/hyprwm/Hyprland";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nix-gaming, nixpkgs, home-manager, hyprland, nvf, ... } @ inputs:
    let
        nixLib = nixpkgs.lib;
        homeLib = home-manager.lib;

        system = "x86_64-linux";

        pkgs = import nixpkgs {
            system = "${system}";
            config.allowUnfree = true;
        };

        user = {
            info = {
                username = "oslamelon";
            };
            system = "x86_64-linux";
            theme = "anby";
        };

        username = "oslamelon";
    in {
        nixosConfigurations = {
            ${username} = nixLib.nixosSystem {
            specialArgs = {  inherit inputs system user;  };
            modules = [ 
                ./system/configuration.nix 
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
            ${username} = homeLib.homeManagerConfiguration {
                inherit pkgs;
                extraSpecialArgs = {  inherit inputs user;  };
                modules = [  
                    hyprland.homeManagerModules.default
                    ./home/home.nix
                ];
            };
        };
        devShells.${system} = {
            default = ( import ./shell/clang.nix {inherit pkgs;} );
            clang = ( import ./shell/clang.nix {inherit pkgs;} );
        };
    };
}
