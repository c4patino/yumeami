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
    cmake
    conan
    vcpkg-tool
  ];

  buildInputs = with pkgs; [
    clang
    gtest
    lcov
    vcpkg
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
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
  '';
}
