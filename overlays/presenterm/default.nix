{...}: final: prev: {
  presenterm = prev.presenterm.overrideAttrs (oldAttrs: rec {
    pname = "presenterm";
    version = "0.16.1";

    src = final.fetchFromGitHub {
      owner = "mfontanini";
      repo = "presenterm";
      rev = "v${version}";
      sha256 = "sha256-mIJktrgBweaaLD2YaRcs0vP5hKRy/kMN/HEnwO323DA=";
    };
    cargoDeps = final.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-OlZXf8Wg32mXGDGbavLVf1ELoqqSmc8z9DNpvGOfAJ8=";
    };

    cargoBuildFeatures = [];
    cargoCheckFeatures = [];
  });
}
