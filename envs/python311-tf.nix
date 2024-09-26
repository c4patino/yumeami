{ pkgs ? import <nixpkgs> { 
    config = {
        allowUnfree = true;
        cudaSupport = true;
    };
}}: pkgs.mkShell {
    name = "python311-dev";

    nativeBuildInputs = with pkgs; [
        poetry

        python311Full
        python311Packages.virtualenv

		# Tensorflow with CUDA support is a pain to set up, so lets just use the one built in to Nix
		python311Packages.tensorflowWithCuda

        # Won't actually use the matplotlib installed here, but needed to set up environment
        python311Packages.matplotlib

		# Won't actually use the OpenCV installed here, but this sets up env vars
        (python311Packages.opencv4.override { enableGtk3 = true; })
    ];

    shell = pkgs.zsh;

    shellHook = ''
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.libGL}/lib
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.glib.out}/lib
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/run/opengl-driver/lib
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH
    '';
}
