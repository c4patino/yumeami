{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption getExe;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.apps.launchers.anyrun";
  cfg = getAttrByNamespace config base;

  compileSCSS = name: source: "${pkgs.runCommandLocal name {} ''
    mkdir -p $out
    ${getExe pkgs.sassc} -t expanded '${source}' > $out/${name}.css
  ''}/${name}.css";
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "Anyrun";
  };

  config = mkIf cfg.enable {
    programs.anyrun = {
      enable = true;
      config = {
        plugins = [
          "${pkgs.anyrun}/lib/libapplications.so"
          "${pkgs.anyrun}/lib/libdictionary.so"
          "${pkgs.anyrun}/lib/libwebsearch.so"
        ];

        x = {fraction = 0.5;};
        y = {fraction = 0.3;};
        width = {fraction = 0.3;};
        hideIcons = false;
        ignoreExclusiveZones = false;
        layer = "overlay";
        hidePluginInfo = true;
        closeOnClick = false;
        showResultsImmediately = false;
        maxEntries = null;
      };

      extraCss = builtins.readFile (compileSCSS "style" ./style.scss);

      extraConfigFiles = {
        "dictionary.ron".text = ''
          Config(
            prefix: ":def",
          )
        '';
        "applications.ron".text = ''
          Config(
            desktop_actions: false,
            max_entries: 10,
          )
        '';
        "websearch.ron".text = ''
          Config(
            prefix: "?",
            engines: [
              Google,
              Custom(
                name: "nixpkgs",
                url: "search.nixos.org/packages?query={}&channel=unstable",
              ),
            ],
          )
        '';
      };
    };
  };
}
