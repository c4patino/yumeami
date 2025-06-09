{pkgs, ...}:
pkgs.writeShellScriptBin "nr" ''
  set -euo pipefail

  usage() {
    cat <<EOF
  Usage:
    nr switch <hostname>     Rebuild and switch configuration on <hostname> using nixos-rebuild.
    nr --help                Show this help message.
  EOF
  }

  if [[ "$#" -lt 1 ]]; then
    echo "Error: Missing subcommand."
    usage
    exit 1
  fi

  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    usage
    exit 0
  fi

  if [ "$#" -lt 2 ]; then
    echo "Usage: nr <subcommand> <hostname>"
    exit 1
  fi

  SUBCOMMAND="$1"
  HOSTNAME="$2"

  case "$SUBCOMMAND" in
    switch)
      if [[ -z "$HOSTNAME" ]]; then
        echo "Error: Missing hostname for 'switch' subcommand."
        usage
        exit 1
      fi

      echo "Running nixos-rebuild switch for host: $HOSTNAME"
      sudo nixos-rebuild switch \
        --flake ~/dotfiles#"$HOSTNAME" \
        --target-host "c4patino@$HOSTNAME" \
        --use-remote-sudo
      ;;
    *)
      echo "Error: Unknown subcommand '$SUBCOMMAND'"
      usage
      exit 1
      ;;
  esac
''
