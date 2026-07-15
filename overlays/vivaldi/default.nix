# TODO: SWITCH THIS OUT TO USE THE STABLE CHANNEL ONCE NIXPKGS FIXES THE VERSION
# {...}: final: prev: {
#   vivaldi = (prev.vivaldi.override
{channels, ...}: final: prev: {
  vivaldi = (channels.nixpkgs-unstable.vivaldi.override
    {
      proprietaryCodecs = true;
      enableWidevine = true;
      commandLineArgs = final.lib.concatStringsSep " " [
        "--ozone-platform=wayland"
        "--enable-features=UseOzonePlatform"
        "--enable-features=WebRTCPipeWireCapturer"
        "--use-cmd-decoder=validating"
      ];
    }).overrideAttrs (old: {
    postInstall = ''
      wrapProgram "$out/bin/vivaldi" \
        --set XDG_SESSION_TYPE wayland \
        --set GTK_USE_PORTAL 1 \
        --set QT_QPA_PLATFORM wayland
    '';
  });
}
