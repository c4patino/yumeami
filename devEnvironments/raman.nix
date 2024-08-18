{ pkgs ? import <nixpkgs> { 
    config = {
        allowUnfree = true;
        cudaSupport = true;
    };
}}: pkgs.mkShell {
    name = "raman";

    nativeBuildInputs = with pkgs; [
        gtk3
        fiji
    ];

    shell = pkgs.zsh;

    runScript = "zsh";

    GSETTINGS_SCHEMA_DIR="${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";

    shellHook = ''
    '';
}
