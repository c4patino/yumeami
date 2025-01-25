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
    clang-tools
    clang
    cmake
    conan
    cppcheck
    gtest
    lcov
    vcpkg
    vcpkg-tool
  ];

  packages = with pkgs; [
    codespell
    doxygen
    gdb
  ];

  shell = pkgs.zsh;

  shellHook = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
  '';
}
