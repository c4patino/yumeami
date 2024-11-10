{lib, ...}: {
  imports = [
    ./android-studio.nix
    ./neovim.nix
    ./idea.nix
    ./pycharm.nix
    ./vscode.nix
  ];
}
