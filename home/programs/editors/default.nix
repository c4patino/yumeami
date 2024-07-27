{ lib, ... }: {
    imports = [
        ./neovim.nix
        ./idea.nix
        ./pycharm.nix
        ./vscode.nix
    ];
}
