{pkgs}:
pkgs.writeShellScriptBin "ignis-vault-sync" ''
  set -euo pipefail
  set -x

  VAULT_ROOT="/var/lib/ignis/vaults"
  DATA_DIR="/var/lib/ignis/data"
  PULL_INTERVAL=300

  for vault in "$VAULT_ROOT"/*/; do
    [ -d "$vault/.git" ] || continue

    cd "$vault"
    name=$(basename "$vault")

    now=$(date +%s)

    last_pull_file="$DATA_DIR/.last-pull-$name"
    last_pull=0
    [ -f "$last_pull_file" ] && last_pull=$(cat "$last_pull_file")

    if [ $((now - last_pull)) -ge $PULL_INTERVAL ]; then
      ${pkgs.git}/bin/git pull --rebase 2>/dev/null || true
      echo "$now" > "$last_pull_file"
    fi

    if ! ${pkgs.git}/bin/git diff --quiet 2>/dev/null || ! ${pkgs.git}/bin/git diff --cached --quiet 2>/dev/null || [ -n "$(${pkgs.git}/bin/git ls-files --others --exclude-standard 2>/dev/null)" ]; then
      newest=$(${pkgs.findutils}/bin/find . -not -path './.git/*' -type f -printf '%T@\n' 2>/dev/null | sort -rn 2>/dev/null | head -1) || true
      newest_int=$(echo "$newest" | cut -d. -f1)

      if [ -z "$newest_int" ] || [ $((now - newest_int)) -ge 60 ]; then
        ${pkgs.git}/bin/git add -A 2>/dev/null
        ${pkgs.git}/bin/git commit -m "$(date -u +"docs(%Y/%m/%d): obsidian automatic vault backup")" 2>/dev/null
        ${pkgs.git}/bin/git push 2>/dev/null
      fi
    fi
  done
''
