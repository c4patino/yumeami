{...}: final: prev: {
  opencode = prev.opencode.overrideAttrs (oldAttrs: let
    version = "0.3.43";
    src = final.fetchFromGitHub {
      owner = "sst";
      repo = "opencode";
      rev = "v${version}";
      hash = "sha256-EM44FkMPPkRChuLcNEEK3n4dLc5uqnX7dHROsZXyr58=";
    };
    vendorHash = "sha256-/YxvM+HZM4aRqcjUiSX0D1DhhMJkmLdh7G4+fPqtnic=";
    nodeModulesHash =
      {
        "aarch64-darwin" = "sha256-TAeFDsHGFJnUyp20ec+Rxp4t1FrWKfbtnxsE8PnLS0o=";
        "aarch64-linux" = "sha256-F056MWf2dNAO21ezEvWg689WUibtz4Q4mcSuDuSY5EM=";
        "x86_64-darwin" = "sha256-AN1Ha/les1ByJGfVkLDibfxjPouC0tAZ//EN3vDi1Hc=";
        "x86_64-linux" = "sha256-XIRV1QrgRHnpJyrgK9ITxH61dve7nWfVoCPs3Tc8nuU=";
      }.${
        final.system
      };
  in {
    inherit version src;

    # Patch the inner buildGoModule (tui)
    tui = oldAttrs.tui.overrideAttrs (_: {
      inherit version;
      src = "${src}/packages/tui";
      vendorHash = vendorHash;
    });

    # Patch the node_modules derivation
    node_modules = oldAttrs.node_modules.overrideAttrs (_: {
      inherit version src;
      outputHash = nodeModulesHash;
    });
  });
}
