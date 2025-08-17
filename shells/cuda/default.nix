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
    cudaPackages.cuda_nvcc
    cudaPackages.cudatoolkit
  ];

  shellHook = ''
    export CUDA_ROOT="${pkgs.cudaPackages.cudatoolkit}"
  '';
}
