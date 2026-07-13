{pkgs, ...}:
pkgs.writeShellScriptBin "check-autobrr-space" ''
  set -euo pipefail

  if [ "$#" -ne 2 ]; then
    echo "Error: Missing argument" >&2
    exit 1
  fi

  parse_space() {
    local space="''${1^^}"
    space="''${space%B}"
    ${pkgs.coreutils}/bin/numfmt --from=iec "$space"
  }

  required_space=$(parse_space "$1")
  torrent_size="$2"
  path="/mnt/nfs/autobrr"

  available_space=$(${pkgs.coreutils}/bin/df --output=avail -B1 "$path" | \
    ${pkgs.gawk}/bin/awk 'END {print $1}')
  remaining_space=$((available_space - torrent_size))

  [ "$remaining_space" -gt "$required_space" ]
''
