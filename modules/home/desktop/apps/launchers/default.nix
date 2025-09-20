{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) types mkOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;

  base = "${namespace}.desktop.apps.launchers";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    launcher = mkOption {
      type = types.nullOr (types.enum ["anyrun" "walker"]);
      default = null;
      description = "Which launcher to enable (anyrun, walker, or null for none).";
    };
  };

  config = let
    launcherVal = cfg.launcher;
  in
    lib.mkMerge [
      (lib.mkIf (launcherVal == "anyrun") {
        ${namespace}.desktop.apps.launchers.anyrun.enable = true;
      })
      (lib.mkIf (launcherVal == "walker") {
        ${namespace}.desktop.apps.launchers.walker.enable = true;
      })
    ];
}
