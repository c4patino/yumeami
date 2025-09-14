{
  pkgs,
  mkShell,
  ...
}:
mkShell {
  nativeBuildInputs = with pkgs; [
    maven
  ];

  buildInputs = with pkgs; [
    jdk23
  ];

  packages = with pkgs; [
    jdt-language-server
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
  '';
}
