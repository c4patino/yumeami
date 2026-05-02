{
  lib,
  stdenv,
  fetchFromGitHub,
  pkgs,
  kernel ? pkgs.linuxPackages_latest.kernel,
  ...
}:
stdenv.mkDerivation {
  pname = "imx471";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "BenBJD";
    repo = "imx471-dkms";
    rev = "main";
    hash = "sha256-nekc4j6k8UJx0oOwBep93yMkFehK5qE67zjZmcUyVck=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  hardeningDisable = ["pic" "format"];

  buildPhase = ''
    runHook preBuild

    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$(pwd) \
      modules

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/media/i2c
    cp imx471.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/media/i2c/

    runHook postInstall
  '';

  meta = {
    description = "IMX471 camera driver";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
}
