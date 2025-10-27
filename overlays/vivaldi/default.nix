{...}: final: prev: {
  vivaldi = (prev.vivaldi.override
    {
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
