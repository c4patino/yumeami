{
  config,
  lib,
  pkgs,
}:
pkgs.writeShellScript "openspec-repo-sync" ''
  set -euo pipefail

  IDLE_THRESHOLD=$((10 * 60))
  PULL_INTERVAL=$((5 * 60))

  OPENSPEC_ROOT=${lib.escapeShellArg "${config.home.homeDirectory}/openspec"}
  [ -d "$OPENSPEC_ROOT" ] || exit 0

  DATA_DIR=${lib.escapeShellArg "${config.home.homeDirectory}/.local/state/openspec-repo-sync"}
  mkdir -p "$DATA_DIR"

  for repo in "$OPENSPEC_ROOT"/*/; do
    [ -d "$repo/.git" ] || continue

    cd "$repo"
    name=$(basename "$repo")

    last_pull_file="$DATA_DIR/.last-pull-$name"
    last_pull=0

    if [ -f "$last_pull_file" ]; then
      read -r last_pull < "$last_pull_file"
    fi

    now=$(date +%s)

    if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ]; then
      echo "Interrupted rebase detected for $name"

      if ! ${pkgs.git}/bin/git fetch origin; then
        echo "Unable to fetch origin; leaving $name untouched" >&2
        continue
      fi

      ${pkgs.git}/bin/git rebase --abort
      ${pkgs.git}/bin/git reset --hard origin/main
      continue
    fi

    if [ $((now - last_pull)) -ge "$PULL_INTERVAL" ] &&
       ${pkgs.git}/bin/git diff --quiet && ${pkgs.git}/bin/git diff --cached --quiet && [ -z "$(${pkgs.git}/bin/git ls-files --others --exclude-standard)" ]; then
      if ! ${pkgs.git}/bin/git pull --rebase; then
        echo "git pull failed for $name; will recover on next run" >&2
        continue
      fi

      printf '%s\n' "$now" > "$last_pull_file"
    fi

    if ${pkgs.git}/bin/git diff --quiet && ${pkgs.git}/bin/git diff --cached --quiet && [ -z "$(${pkgs.git}/bin/git ls-files --others --exclude-standard)" ]; then
      continue
    fi

    newest=$(${pkgs.findutils}/bin/find . -not -path './.git/*' -type f -printf '%T@\n' 2>/dev/null | sort -rn 2>/dev/null | head -1) || true

    newest_int="''${newest%%.*}"
    if [ -n "$newest_int" ] &&
       [ $((now - newest_int)) -lt "$IDLE_THRESHOLD" ]; then
      continue
    fi

    ${pkgs.git}/bin/git add -A
    if ! ${pkgs.git}/bin/git commit -m "$(date -u +"docs(%Y/%m/%d): automatic OpenSpec backup")"; then
      echo "git commit failed for $name" >&2
      continue
    fi

    if ! ${pkgs.git}/bin/git pull --rebase; then
      echo "git pull failed for $name; will recover on next run" >&2
      continue
    fi

    printf '%s\n' "$now" > "$last_pull_file"

    if ! ${pkgs.git}/bin/git push; then
      echo "git push failed for $name; local commit retained" >&2
      continue
    fi
  done
''
