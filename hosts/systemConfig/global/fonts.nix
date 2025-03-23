{pkgs, ...}: {
    fonts = {
        enableDefaultPackages = true;
        packages = with pkgs; [ 
            nerd-fonts.noto
            nerd-fonts.symbols-only
            noto-fonts-cjk-sans
        ];

    };
}
