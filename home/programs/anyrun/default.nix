{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.anyrun;

  compileSCSS = name: source: "${pkgs.runCommandLocal name {} ''
    mkdir -p $out
    ${lib.getExe pkgs.sassc} -t expanded '${source}' > $out/${name}.css
  ''}/${name}.css";
in {
  options.anyrun.enable = mkEnableOption "Anyrun";

  config = mkIf cfg.enable {
    programs.anyrun = {
      enable = true;
      config = {
        plugins = with inputs.anyrun.packages.${pkgs.system}; [
          applications
          dictionary
          websearch
        ];

        width = {fraction = 0.3;};
        hideIcons = false;
        ignoreExclusiveZones = false;
        layer = "overlay";
        hidePluginInfo = false;
        closeOnClick = false;
        showResultsImmediately = false;
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
