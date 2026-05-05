{pkgs, ...}: let
  gpgConf = pkgs.writeText "gpg.conf" ''
    no-tty
    batch
  '';
in
  pkgs.writeShellScriptBin "generate-gpg-keys" ''
    set -euo pipefail

    usage() {
      echo "Usage: generate-gpg-keys [OPTIONS]"
      echo ""
      echo "Generate a new GPG key pair and export armor files."
      echo ""
      echo "OPTIONS:"
      echo "  -e, --email <email>    Email address for the key (required)"
      echo "  -n, --name <name>     Name for the key (default: GPG Key)"
      echo "  -o, --output <dir>    Output directory (default: current directory)"
      echo "  -h, --help            Show this help message"
      exit 1
    }

    email=""
    name="GPG Key"
    output="."

    while [[ $# -gt 0 ]]; do
      case $1 in
        -e|--email)
          email="$2"
          shift 2
          ;;
        -n|--name)
          name="$2"
          shift 2
          ;;
        -o|--output)
          output="$2"
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

    if [[ -z "$email" ]]; then
      echo "Error: --email is required"
      usage
    fi

    keybase=$(echo "$email" | cut -d@ -f1)
    tempdir=$(mktemp -d)
    trap "rm -rf $tempdir" EXIT

    cp ${gpgConf} "$tempdir/gpg.conf"

    cat > "$tempdir/gen-key.batch" <<EOF
    Key-Type: RSA
    Key-Length: 4096
    Subkey-Type: RSA
    Subkey-Length: 4096
    Name-Real: $name
    Name-Email: $email
    Expire-Date: 0
    %no-protection
    %commit
    EOF

    GNUPGHOME="$tempdir" gpg --homedir "$tempdir" --gen-key --batch "$tempdir/gen-key.batch"

    if ! GNUPGHOME="$tempdir" gpg --homedir "$tempdir" --list-secret-keys "$email" > /dev/null 2>&1; then
      echo "Error: Failed to generate GPG key"
      exit 1
    fi

    keygrip=$(GNUPGHOME="$tempdir" gpg --homedir "$tempdir" --list-secret-keys --with-keygrip "$email" 2>/dev/null | grep "Keygrip" | head -1 | awk '{print $3}')

    mkdir -p "$output"

    GNUPGHOME="$tempdir" gpg --homedir "$tempdir" --armor --export-secret-keys "$email" > "$output/''${keybase}.private.asc"
    GNUPGHOME="$tempdir" gpg --homedir "$tempdir" --armor --export "$email" > "$output/''${keybase}.public.asc"

    chmod 600 "$output/''${keybase}.private.asc" "$output/''${keybase}.public.asc"

    echo "Generated GPG keys for $email"
    echo "  Private: $output/''${keybase}.private.asc"
    echo "  Public:  $output/''${keybase}.public.asc"
  ''
