{ pkgs, lib, config, inputs, ... }: {
    options = {
        pycharm.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Pycharm";
        };
    };

    config = lib.mkIf config.pycharm.enable {
        home.packages = with pkgs; [ jetbrains.pycharm-professional ];

        home.file = {
            ".ideavimrc".source = inputs.dotfiles + "/ideavimrc";
        };
    };
}
