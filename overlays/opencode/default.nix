{...}: final: prev: {
  opencode = prev.opencode.overrideAttrs (oldAttrs: {
    node_modules = oldAttrs.node_modules.overrideAttrs (nmOld: {
      buildPhase = ''
        runHook preBuild

        export BUN_INSTALL_CACHE_DIR=$(mktemp -d)

        bun install \
          --filter=opencode \
          --force \
          --frozen-lockfile \
          --ignore-scripts \
          --linker=hoisted \
          --no-progress \
          --production

        runHook postBuild
      '';

      outputHash =
        {
          x86_64-linux = "sha256-kXsLJ/Ck9epH9md6goCj3IYpWog/pOkfxJDYAxI14Fg=";
          aarch64-linux = "sha256-DHzDyk7BWYgBNhYDlK3dLZglUN7bMiB3acdoU7djbxU=";
          x86_64-darwin = "sha256-OTEK9SV9IxBHrJlf+F4lI7gF0Gtvik3c7d1mp+4a3Zk=";
          aarch64-darwin = "sha256-qlLfus/cyrI0HtwVLTjPTdL7OeIYjmH9yoNKa6YNBkg=";
        } .${
          prev.stdenv.hostPlatform.system
        };

      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    });
  });
}
