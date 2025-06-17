{
  pkgs,
  mkShell,
}:
mkShell {
  nativeBuildInputs = with pkgs; [
    cmake
    conan
    vcpkg-tool
  ];

  buildInputs = with pkgs; [
    clang
    gtest
    lcov
  ];

  packages = with pkgs; [
    clang-tools
    codespell
    cppcheck
    doxygen
    gdb
  ];

  shell = pkgs.zsh;

  shellHook = ''
    export LIBRARY_PATH="${pkgs.libgcc}/lib:$LIBRARY_PATH";
    export LIBRARY_PATH="${pkgs.glibc}/lib:$LIBRARY_PATH";

    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
  '';
}
