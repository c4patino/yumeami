{
  lib,
  fetchzip,
  stdenvNoCC,
  installShellFiles,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tanzu-cli";
  version = "1.5.4";

  src = fetchzip {
    url = "https://github.com/vmware-tanzu/tanzu-cli/releases/download/v${finalAttrs.version}/tanzu-cli-linux-amd64.tar.gz";
    hash = "sha256-1Q5v9izcPqsHy0zcdl2aoUSKbaidB7ZNZuzgIdKhN/A=";
    stripRoot = false;
  };

  nativeBuildInputs = [installShellFiles];

  installPhase = ''
    runHook preInstall

    install -Dm755 ${finalAttrs.src}/v${finalAttrs.version}/tanzu-cli-linux_amd64 $out/bin/tanzu

    runHook postInstall
  '';

  meta = {
    description = "CLI tool to manage VMware Tanzu platforms";
    homepage = "https://github.com/vmware-tanzu/tanzu-cli";
    changelog = "https://github.com/vmware-tanzu/tanzu-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    mainProgram = "tanzu";
    platforms = ["x86_64-linux"];
    maintainers = with lib.maintainers; [
      c4patino
    ];
  };
})
