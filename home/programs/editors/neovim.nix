{ lib, config, pkgs, inputs, ... }: {
    options = {
        neovim.enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable neovim";
        };
    };

    config = lib.mkIf config.neovim.enable {
        home.packages = with pkgs; [
            inputs.nixvim-config.packages.x86_64-linux.default
        ];

        # programs.nixvim = {
        #     enable = true;
        #     defaultEditor = true;
        #
        #     vimdiffAlias = true;
        # };
    };
}
