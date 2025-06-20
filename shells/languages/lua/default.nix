{
  pkgs,
  mkShell,
}:
mkShell {
  nativeBuildInputs = with pkgs; [
    lua
  ];

  packages = with pkgs; [
    stylua
  ];

  shell = pkgs.zsh;

  shellHook = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
  '';
}
