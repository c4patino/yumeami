{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) types;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace mkNullableOpt;

  base = "${namespace}.desktop.apps.launchers";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    launcher = mkNullableOpt (types.enum ["anyrun" "walker"]) null "Which launcher to enable (anyrun, walker, or null for none).";
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
