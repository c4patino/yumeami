{pkgs, ...}:
pkgs.writeShellScriptBin "ignis-vault-key-provision" ''
  set -euo pipefail

  DATA_DIR="/var/lib/ignis/data"
  SSH_DIR="$DATA_DIR/.ssh"
  KEY_FILE="$SSH_DIR/id_ed25519"
  PUBLIC_KEY_FILE="$KEY_FILE.pub"
  HOSTNAME="$(< /proc/sys/kernel/hostname)"

  umask 077
  mkdir -p "$SSH_DIR"

  if [ ! -f "$KEY_FILE" ]; then
    ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -N "" -f "$KEY_FILE" -C "ignis-vault-sync@$HOSTNAME"

    echo "# ==============================================================================="
    echo "# IGNIS VAULT SYNC PUBLIC KEY"
    echo "# ==============================================================================="
    cat "$PUBLIC_KEY_FILE"
  fi

  ${pkgs.git}/bin/git config -f "$DATA_DIR/.gitconfig" user.name "C4 Patino"
  ${pkgs.git}/bin/git config -f "$DATA_DIR/.gitconfig" user.email "c4patino@gmail.com"
  ${pkgs.git}/bin/git config -f "$DATA_DIR/.gitconfig" core.sshCommand "${pkgs.openssh}/bin/ssh -i $KEY_FILE -o StrictHostKeyChecking=accept-new"
  ${pkgs.git}/bin/git config -f "$DATA_DIR/.gitconfig" gpg.format ssh
  ${pkgs.git}/bin/git config -f "$DATA_DIR/.gitconfig" user.signingkey "$PUBLIC_KEY_FILE"
  ${pkgs.git}/bin/git config -f "$DATA_DIR/.gitconfig" commit.gpgsign true
''
