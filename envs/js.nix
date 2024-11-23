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
  name = "js-dev";

  nativeBuildInputs = with pkgs; [
    nodejs
    nodePackages.pnpm
    yarn

    vscode-js-debug
    nodePackages.prettier
  ];

  shell = pkgs.zsh;

  shellHook = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
  '';
}
