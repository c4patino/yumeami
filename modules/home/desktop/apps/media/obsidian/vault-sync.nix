{
  lib,
  pkgs,
  vaults,
}:
pkgs.writeShellScriptBin "obsidian-vault-sync" ''
  set -euo pipefail

  IDLE_THRESHOLD=$((5 * 60))
  PULL_INTERVAL=$((1 * 60))

  VAULTS=(${lib.escapeShellArgs vaults})

  DATA_DIR="$HOME/.local/state/obsidian-vault-sync"
  mkdir -p "$DATA_DIR"

  for vault in "''${VAULTS[@]}"; do
    [ -d "$vault/.git" ] || continue

    cd "$vault"
    name=$(basename "$vault")

    branch=$(${pkgs.git}/bin/git branch --show-current)
    if [ -z "$branch" ] && [ -f .git/rebase-merge/head-name ]; then
      branch=$(<.git/rebase-merge/head-name)
      branch="''${branch#refs/heads/}"
    elif [ -z "$branch" ] && [ -f .git/rebase-apply/head-name ]; then
      branch=$(<.git/rebase-apply/head-name)
      branch="''${branch#refs/heads/}"
    fi

    if [ "$branch" != "main" ]; then
      echo "Skipping $name: not on main"
      continue
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

    if ! ${pkgs.git}/bin/git fetch origin; then
      echo "git fetch failed for $name; leaving local changes untouched" >&2
      continue
    fi

    commit_msg=$(date -u +"docs(%Y/%m/%d): obsidian automatic vault backup")

    remote_subject=$(${pkgs.git}/bin/git log -1 --format=%s origin/main 2>/dev/null || true)
    local_subject=$(${pkgs.git}/bin/git log -1 --format=%s HEAD 2>/dev/null || true)
    if [ "$remote_subject" = "$commit_msg" ]; then
      if ! ${pkgs.git}/bin/git reset --soft origin/main; then
        echo "git reset --soft failed for $name" >&2
        continue
      fi

      _amend="--amend"
    elif [ "$local_subject" = "$commit_msg" ]; then
      if ! ${pkgs.git}/bin/git reset --soft origin/main; then
        echo "git reset --soft failed for $name" >&2
        continue
      fi

      _amend=""
    else
      _amend=""
    fi

    ${pkgs.git}/bin/git add -A
    if ! ${pkgs.git}/bin/git commit $_amend -m "$commit_msg"; then
      echo "git commit failed for $name" >&2
      continue
    fi

    if ! ${pkgs.git}/bin/git push --force-with-lease; then
      echo "git push failed for $name; local commit retained" >&2
      continue
    fi

    printf '%s\n' "$now" > "$last_pull_file"
  done
''
