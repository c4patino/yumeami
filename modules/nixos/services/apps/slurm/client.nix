{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkAfter optionalString;
  inherit (lib.${namespace}) getAttrByNamespace mkPersistDir;
  base = "${namespace}.services.apps.slurm";
  cfg = getAttrByNamespace config base;
  inherit (config.networking) hostName;
in {
  config = mkIf (builtins.hasAttr hostName cfg.nodeMap) {
    services.slurm = {
      client.enable = true;

      extraConfig = mkAfter ''
        SlurmdParameters=allow_ecores

        TaskProlog=${inputs.dotfiles + "/slurm/prolog.sh"}
        TaskEpilog=${inputs.dotfiles + "/slurm/epilog.sh"}
      '';

      extraCgroupConfig = ''
        ConstrainCores=yes
        ConstrainDevices=yes
        ConstrainRAMSpace=yes
      ''
      + optionalString (hostName != "chibi") ''
        ConstrainSwapSpace=yes
        AllowedSwapSpace=0
      '';
    };

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "slurm" "/var/spool/slurmd")
    ];
  };
}
