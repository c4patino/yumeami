{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "helix";
  version = "0.1.3";

  src =
    {
      x86_64-linux = fetchurl {
        url = "https://helix.micro1.ai/cli/releases/releases/${version}/stable/linux/x86_64/helix";
        hash = "sha256-VosnEOJf33HoSwlIYA4ucBnQ+FQi++L/eipqnCJDlho=";
      };
      aarch64-linux = fetchurl {
        url = "https://helix.micro1.ai/cli/releases/releases/${version}/stable/linux/aarch64/helix";
        hash = "sha256-ADYIW0dPkGeeeQk7X5BanIYm7bl3mDEbzEazCDYNuZc=";
      };
      x86_64-darwin = fetchurl {
        url = "https://helix.micro1.ai/cli/releases/releases/${version}/stable/macos/x86_64/helix";
        hash = "sha256-e1GCUjsJqB0crigtixx1qZVFquPtdsgxoK+j6tHfwQg=";
      };
      aarch64-darwin = fetchurl {
        url = "https://helix.micro1.ai/cli/releases/releases/${version}/stable/macos/aarch64/helix";
        hash = "sha256-YMhEEufJzvuuU/Sd6HiyGYiREgnFyH+OVDF3cPUUmh4=";
      };
    }.${
      stdenv.hostPlatform.system
    }
    or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  # The artifact is the raw executable, not an archive.
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/helix
    runHook postInstall
  '';

  meta = {
    description = "Helix CLI - Post-modern text editor command-line interface";
    homepage = "https://helix.micro1.ai/cli/";
    changelog = "https://helix.micro1.ai/cli/releases/";
    license = lib.licenses.mpl20;
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    maintainers = ["c4patino"];
    mainProgram = "helix";
  };
}
