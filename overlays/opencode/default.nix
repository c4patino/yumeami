# HACK: temporary fix until fix pr is merged in (https://nixpk.gs/pr-tracker.html?pr=440598)
{...}: final: prev: {
  opencode = prev.opencode.overrideAttrs (oldAttrs: let
    version = "0.6.4";
    src = final.fetchFromGitHub {
      owner = "sst";
      repo = "opencode";
      rev = "v${version}";
      hash = "sha256-o7SzDGbWgCh8cMNK+PeLxAw0bQMKFouHdedUslpA6gw=";
    };

    tui = oldAttrs.tui.overrideAttrs (_: {
      inherit src version;
      vendorHash = "sha256-8pwVQVraLSE1DRL6IFMlQ/y8HQ8464N/QwAS8Faloq4=";
    });
  in {
    inherit version src tui;

    buildPhase = ''
      runHook preBuild

      bun build \
        --define OPENCODE_TUI_PATH="'${tui}/bin/tui'" \
        --define OPENCODE_VERSION="'${version}'" \
        --compile \
        --compile-exec-argv="--" \
        --target=bun-${final.system} \
        --outfile=opencode \
        ./packages/opencode/src/index.ts \

      runHook postBuild
    '';
  });
}
