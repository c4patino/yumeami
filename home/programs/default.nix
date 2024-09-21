{ ... }: {
    imports = [
        ./anyrun
        ./editors
        ./media
        ./terminal

        ./browsers.nix
        ./desktop-applications.nix
        ./languages.nix
    ];
}
