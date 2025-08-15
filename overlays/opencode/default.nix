{...}: final: prev: {
  opencode = prev.opencode.overrideAttrs (oldAttrs: let
    version = "0.5.4";
    src = final.fetchFromGitHub {
      owner = "sst";
      repo = "opencode";
      rev = "v${version}";
      hash = "sha256-sQ1le6/OJb22Kehjj4glUsavHE08u0e2I7h8lW9MO9E=";
    };
    nodeModulesHash =
      {
        "aarch64-darwin" = "sha256-/s6eAI1VJ0kXrxP5yTi+jwNqHBCRcoltJC86AT7nVdI=";
        "aarch64-linux" = "sha256-aG5e5HMcxO9P7ciZ9cg8uY1rxDpTOKdR31z0L2d9dxY=";
        "x86_64-darwin" = "sha256-jkAFmTb+cTO/B7a7MgaKqOzZI3QPkM3uW2RULnBcxSI=";
        "x86_64-linux" = "sha256-ql4qcMtuaRwSVVma3OeKkc9tXhe21PWMMko3W3JgpB0=";
      }.${
        final.system
      };
  in {
    inherit version src;

    tui = oldAttrs.tui.overrideAttrs (_: {
      inherit src version;
      vendorHash = "sha256-jINbGug/SPGBjsXNsC9X2r5TwvrOl5PJDL+lrOQP69Q=";
    });

    node_modules = oldAttrs.node_modules.overrideAttrs (_: {
      inherit version src;
      outputHash = nodeModulesHash;
    });
  });
}
