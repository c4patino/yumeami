{ lib, config, ... }: {
    options = {
        vscode.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "enables VSCode";
        };
    };

    config = lib.mkIf config.vscode.enable {
        programs.vscode = {
            enable = true;
        };
    };
}
