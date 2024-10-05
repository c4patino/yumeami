{ lib, config, pkgs, ... }: {
    options = {
        lastpass.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable LastPass CLI";
        };
    };

    config = lib.mkIf config.lastpass.enable {
        home.packages = with pkgs; [ lastpass-cli ];
    };
}
