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
    clang
    conan
    gcc
    vcpkg-tool
  ];

  buildInputs = with pkgs; [
    vcpkg
  ];

  packages = with pkgs; [
    clang-tools
    codespell
    cppcheck
    doxygen
    gdb
    gtest
    lcov
  ];

  shell = pkgs.zsh;

  shellHook = ''
    export LIBRARY_PATH="${pkgs.libgcc}/lib:$LIBRARY_PATH";
    export LIBRARY_PATH="${pkgs.glibc}/lib:$LIBRARY_PATH";

    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
  '';
}
