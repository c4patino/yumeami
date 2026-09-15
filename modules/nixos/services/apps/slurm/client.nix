{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkAfter mkIf mkMerge optionalString;
  inherit (lib.${namespace}) getAttrByNamespace mkPersistDir waitForNetwork;
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

      extraCgroupConfig =
        ''
          ConstrainCores=yes
          ConstrainDevices=yes
          ConstrainRAMSpace=yes
        ''
        + optionalString (hostName != "chibi") ''
          ConstrainSwapSpace=yes
          AllowedSwapSpace=0
        '';
    };

    systemd.services.slurmd = mkMerge [
      waitForNetwork
      {
        requires = ["munged.service"];
        after = ["munged.service"];
      }
    ];

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "slurm" "/var/spool/slurmd" "700")
    ];
  };
}
