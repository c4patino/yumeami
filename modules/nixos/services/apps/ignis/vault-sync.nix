{pkgs}:
pkgs.writeShellScriptBin "ignis-vault-sync" ''
  set -euo pipefail

  IDLE_THRESHOLD=$((5 * 60))
  PULL_INTERVAL=$((1 * 60))

  VAULT_ROOT="/var/lib/ignis/vaults"
  [ -d "$VAULT_ROOT" ] || exit 0

  DATA_DIR="/var/lib/ignis/data"
  mkdir -p "$DATA_DIR"

  for vault in "$VAULT_ROOT"/*/; do
    [ -d "$vault/.git" ] || continue

    cd "$vault"
    name=$(basename "$vault")

    if ! ${pkgs.git}/bin/git check-ignore -q .OBSIDIANTEST; then
      printf '%s\n' '.OBSIDIANTEST' >> .git/info/exclude
    fi

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

      rm -f .OBSIDIANTEST

      if ! ${pkgs.git}/bin/git rebase --abort; then
        echo "Unable to abort rebase for $name; leaving it untouched" >&2
        continue
      fi

      if ! ${pkgs.git}/bin/git reset --hard origin/main; then
        echo "Unable to reset $name to origin/main" >&2
      fi
      continue
    fi

    if [ $((now - last_pull)) -ge "$PULL_INTERVAL" ] &&
       ${pkgs.git}/bin/git diff --quiet && ${pkgs.git}/bin/git diff --cached --quiet && [ -z "$(${pkgs.git}/bin/git ls-files --others --exclude-standard)" ]; then
      if ! ${pkgs.git}/bin/git pull --rebase; then
        echo "git pull failed for $name; resetting to origin/main" >&2
        rm -f .OBSIDIANTEST
        ${pkgs.git}/bin/git rebase --abort || true
        ${pkgs.git}/bin/git fetch origin
        ${pkgs.git}/bin/git reset --hard origin/main
        continue
      fi

      printf '%s\n' "$now" > "$last_pull_file"
    fi

    if ${pkgs.git}/bin/git diff --quiet && ${pkgs.git}/bin/git diff --cached --quiet && [ -z "$(${pkgs.git}/bin/git ls-files --others --exclude-standard)" ]; then
      continue
    fi

    newest=$(
      ${pkgs.findutils}/bin/find . \
        -not -path './.git/*' \
        -not -path './.obsidian/*' \
        -not -path './.OBSIDIANTEST' \
        -type f \
        -printf '%T@\n' 2>/dev/null | \
        sort -rn 2>/dev/null | \
        head -1
    ) || true

    newest_int="''${newest%%.*}"
    if [ -n "$newest_int" ] &&
       [ $((now - newest_int)) -lt "$IDLE_THRESHOLD" ]; then
      continue
    fi

    ${pkgs.git}/bin/git add -A
    if ! ${pkgs.git}/bin/git commit -m "$(date -u +"docs(%Y/%m/%d): obsidian automatic vault backup")"; then
      echo "git commit failed for $name" >&2
      continue
    fi

    if ! ${pkgs.git}/bin/git pull --rebase; then
      echo "git pull failed for $name; resetting to origin/main" >&2
      rm -f .OBSIDIANTEST
      ${pkgs.git}/bin/git rebase --abort || true
      ${pkgs.git}/bin/git fetch origin
      ${pkgs.git}/bin/git reset --hard origin/main
      continue
    fi

    printf '%s\n' "$now" > "$last_pull_file"

    if ! ${pkgs.git}/bin/git push; then
      echo "git push failed for $name; local commit retained" >&2
      continue
    fi
  done
''
