{pkgs, ...}:
pkgs.writeShellScriptBin "generate-ssh-keys" ''
  set -euo pipefail

  usage() {
    echo "Usage: generate-ssh-keys [OPTIONS]"
    echo ""
    echo "Generate a new SSH key pair."
    echo ""
    echo "OPTIONS:"
    echo "  -c, --comment <comment>    Comment for the key (required)"
    echo "  -o, --output <dir>        Output directory (default: current directory)"
    echo "  -t, --type <type>         Key type: ed25519, ecdsa, rsa (default: ed25519)"
    echo "  -b, --bits <bits>         Key bits for RSA/ECDSA (default: 4096)"
    echo "  -h, --help                Show this help message"
    exit 1
  }

  comment=""
  output="."
  key_type="ed25519"
  bits="4096"

  while [[ $# -gt 0 ]]; do
    case $1 in
      -c|--comment)
        comment="$2"
        shift 2
        ;;
      -o|--output)
        output="$2"
        shift 2
        ;;
      -t|--type)
        key_type="$2"
        shift 2
        ;;
      -b|--bits)
        bits="$2"
        shift 2
        ;;
      -h|--help)
        usage
        ;;
      *)
        echo "Unknown option: $1"
        usage
        ;;
    esac
  done

  if [[ -z "$comment" ]]; then
    echo "Error: --comment is required"
    usage
  fi

  keybase=$(echo "$comment" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')

  case "$key_type" in
    ed25519)
      key_file="$output/''${keybase}-ed25519"
      ;;
    ecdsa)
      key_file="$output/''${keybase}-ecdsa"
      ;;
    rsa)
      key_file="$output/''${keybase}-rsa"
      ;;
    *)
      echo "Error: Invalid key type: $key_type"
      usage
      ;;
  esac

  mkdir -p "$output"

  if [[ "$key_type" == "ed25519" ]]; then
    ssh-keygen -t ed25519 -C "$comment" -N "" -f "$key_file"
  elif [[ "$key_type" == "ecdsa" ]]; then
    ssh-keygen -t ecdsa -b "$bits" -C "$comment" -N "" -f "$key_file"
  elif [[ "$key_type" == "rsa" ]]; then
    ssh-keygen -t rsa -b "$bits" -C "$comment" -N "" -f "$key_file"
  fi

  chmod 600 "$key_file" "$key_file.pub"

  echo "Generated SSH key"
  echo "  Private: $key_file"
  echo "  Public:  $key_file.pub"
''
