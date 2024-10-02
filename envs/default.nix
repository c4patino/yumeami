{ inputs, ... }: {
	systems = [ "x86_64-linux" "aarch64-linux" ];

	perSystem = { config, pkgs, system, ... }:
	let
		pkgs = import inputs.nixpkgs {
			inherit system;
			config = {
				allowUnfree = true;
			};
		};
		cudaPkgs = import inputs.nixpkgs {
			inherit system;
			config = {
				allowUnfree = true;
				cudaSupport = true;
			};
		};
	in
	{
		devShells = {
			c-dev = (import ./c.nix { inherit pkgs; });
			cpp-dev = (import ./cpp.nix { inherit pkgs; });
			go-dev = (import ./go.nix { inherit pkgs; });
			js-dev = (import ./js.nix { inherit pkgs; });
			python311-dev = (import ./python311.nix { inherit pkgs; });
			python311-tf-dev = (import ./python311.nix { inherit pkgs; enableTensorflow = true; });
			python311-torch-dev = (import ./python311.nix { inherit pkgs; enablePyTorch = true; });
			python312-dev = (import ./python312.nix { inherit pkgs; });
			python312-tf-dev = (import ./python312.nix { inherit pkgs; enableTensorflow = true; });
			python312-torch-dev = (import ./python312.nix { inherit pkgs; enablePyTorch = true; });
			rust-dev = (import ./rust.nix { inherit pkgs; });

			c-cuda-dev = (import ./c.nix { pkgs = cudaPkgs; });
			cpp-cuda-dev = (import ./cpp.nix { pkgs = cudaPkgs; });
			go-cuda-dev = (import ./go.nix { pkgs = cudaPkgs; });
			js-cuda-dev = (import ./js.nix { pkgs = cudaPkgs; });
			python311-cuda-dev = (import ./python311.nix { pkgs = cudaPkgs; });
			python311-cuda-tf-dev = (import ./python311.nix { pkgs = cudaPkgs; enableTensorflow = true; });
			python311-cuda-torch-dev = (import ./python311.nix { pkgs = cudaPkgs; enablePyTorch = true; });
			python312-cuda-dev = (import ./python312.nix { pkgs = cudaPkgs; });
			python312-cuda-tf-dev = (import ./python312.nix { pkgs = cudaPkgs; enableTensorflow = true; });
			python312-cuda-torch-dev = (import ./python312.nix { pkgs = cudaPkgs; enablePyTorch = true; });
			rust-cuda-dev = (import ./rust.nix { pkgs = cudaPkgs; });
		};
	};
}
