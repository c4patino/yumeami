{
  config,
  lib,
  pkgs,
}:
pkgs.writeShellScript "openspec-repo-auto-sync" ''
  set -euo pipefail

  IDLE_THRESHOLD=$((10 * 60))
  PULL_INTERVAL=$((5 * 60))

  OPENSPEC_ROOT=${lib.escapeShellArg "${config.home.homeDirectory}/openspec"}
  DATA_DIR=${lib.escapeShellArg "${config.home.homeDirectory}/.local/state/openspec-repo-auto-sync"}

  mkdir -p "$DATA_DIR"

  [ -d "$OPENSPEC_ROOT" ] || exit 0

  for repo in "$OPENSPEC_ROOT"/*/; do
    [ -d "$repo/.git" ] || continue

    cd "$repo"
    name=$(basename "$(pwd)")
    safe_name=$(printf '%s' "$name" | tr -c 'A-Za-z0-9._-' '_')
    last_pull_file="$DATA_DIR/.last-pull-$safe_name"
    last_pull=0

    [ -f "$last_pull_file" ] && read -r last_pull < "$last_pull_file" || true

    now=$(date +%s)

    if [ $((now - last_pull)) -ge $PULL_INTERVAL ]; then
      ${pkgs.git}/bin/git pull --rebase 2>/dev/null || true
      printf '%s\n' "$now" > "$last_pull_file"
    fi

    if ! ${pkgs.git}/bin/git diff --quiet 2>/dev/null || ! ${pkgs.git}/bin/git diff --cached --quiet 2>/dev/null || [ -n "$(${pkgs.git}/bin/git ls-files --others --exclude-standard 2>/dev/null)" ]; then
      newest=$(${pkgs.findutils}/bin/find . -not -path './.git/*' -type f -printf '%T@\n' 2>/dev/null | sort -rn 2>/dev/null | head -1) || true
      newest_int="''${newest%%.*}"

      if [ -z "$newest_int" ] || [ $((now - newest_int)) -ge "$IDLE_THRESHOLD" ]; then
        ${pkgs.git}/bin/git add -A 2>/dev/null
        ${pkgs.git}/bin/git commit -m "$(date -u +"docs(%Y/%m/%d): automatic OpenSpec backup")" 2>/dev/null
        ${pkgs.git}/bin/git push 2>/dev/null
      fi
    fi
  done
''
