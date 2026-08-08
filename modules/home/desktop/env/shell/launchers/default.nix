{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) types;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace mkNullableOpt;

  base = "${namespace}.desktop.env.shell.launchers";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    launcher = mkNullableOpt (types.enum ["anyrun" "walker" "noctalia"]) null "Which launcher to enable";
  };

  config = let
    launcherVal = cfg.launcher;
  in
    lib.mkMerge [
      (lib.mkIf (launcherVal == "anyrun") {
        ${namespace}.desktop.env.shell.launchers.anyrun.enable = true;
      })
      (lib.mkIf (launcherVal == "walker") {
        ${namespace}.desktop.env.shell.launchers.walker.enable = true;
      })
    ];
}
