# NOTE: REMOVE THIS OVERLAY WHEN LAZYGIT GETS UPDATED IN NIXPKGS
# https://github.com/NixOS/nixpkgs/pull/542210
{...}: final: prev: {
  lazygit = prev.lazygit.overrideAttrs (old: rec {
    version = "0.63.1";

    src = final.fetchzip {
      url = "https://github.com/jesseduffield/lazygit/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-vcpd04DEHmtEJtOOYohxHUgNtQfiChErWmNiQle8pvc=";
    };
  });
}
