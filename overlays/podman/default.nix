# TODO: remove this overlay once nixos-26.05 has a fix for
# https://github.com/podman-container-tools/podman/issues/29805 until then, we
# vendor v5.8.4 as an alternative. this causes a regression with gitea-runners
# where it causes a regression where gitea action runners throw "path escapes
# from parent" when crossing a symlink boundary
{...}: final: prev: {
  podman = prev.podman.overrideAttrs (
    old: let
      version = "5.8.4";
    in {
      inherit version;

      src = prev.fetchFromGitHub {
        owner = "podman-container-tools";
        repo = "podman";
        tag = "v${version}";
        hash = "sha256-zhEtMZVKiv1L72EMlwgz8sHpmvhejGp98oW63aPj+rQ=";
      };
    }
  );
}
