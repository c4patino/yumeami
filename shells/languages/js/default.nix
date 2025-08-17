{
  pkgs ?
    import <nixpkgs> {
      config = {
        allowUnfree = true;
        cudaSupport = true;
      };
    },
}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    nodePackages.pnpm
  ];

  buildInputs = with pkgs; [
    nodejs
    yarn
  ];

  packages = with pkgs; [
    nodePackages.prettier
    prettierd
    vscode-js-debug
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
  '';
}
