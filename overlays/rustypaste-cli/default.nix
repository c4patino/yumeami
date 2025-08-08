{...}: final: prev: {
  rustypaste-cli = prev.rustypaste-cli.overrideAttrs (oldAttrs: {
    cargoBuildFeatures = ["use-native-certs"];
  });
}
