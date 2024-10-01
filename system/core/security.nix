{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [ 
        gnupg
    ];

    security = {
        polkit.enable = true;
        rtkit.enable = true;
    };

    programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
    };
}
