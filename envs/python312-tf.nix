{ pkgs ? import <nixpkgs> { 
    config = {
        allowUnfree = true;
        cudaSupport = true;
    };
}}: pkgs.mkShell {
    name = "python312-dev";

    nativeBuildInputs = with pkgs; [
        poetry

        python312Full
        python312Packages.virtualenv

		# Tensorflow with CUDA support is a pain to set up, so lets just use the one built in to Nix
		python312Packages.tensorflowWithCuda

        # Won't actually use the matplotlib installed here, but needed to set up environment
        python312Packages.matplotlib

		# Won't actually use the OpenCV installed here, but this sets up env vars
        (python312Packages.opencv4.override { enableGtk3 = true; })
    ];

    shell = pkgs.zsh;

    shellHook = ''
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.libGL}/lib
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.glib.out}/lib
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/run/opengl-driver/lib
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH
    '';
}
