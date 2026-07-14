{
  dataDir,
  idleThreshold,
  lib,
  openspecRoot,
  pkgs,
  pullInterval,
}:
pkgs.writeShellScript "openspec-repo-auto-sync" ''
  set -u

  OPENSPEC_ROOT=${lib.escapeShellArg openspecRoot}
  DATA_DIR=${lib.escapeShellArg dataDir}
  IDLE_THRESHOLD=${toString idleThreshold}
  PULL_INTERVAL=${toString pullInterval}

  ${pkgs.coreutils}/bin/mkdir -p "$DATA_DIR"

  [ -d "$OPENSPEC_ROOT" ] || exit 0

  repo_has_changes() {
    ! ${pkgs.git}/bin/git -C "$1" diff --quiet \
      || ! ${pkgs.git}/bin/git -C "$1" diff --cached --quiet \
      || [ -n "$(${pkgs.git}/bin/git -C "$1" ls-files --others --exclude-standard)" ]
  }

  now=$(${pkgs.coreutils}/bin/date +%s)

  for repo in "$OPENSPEC_ROOT"/*/; do
    [ -d "$repo/.git" ] || continue

    repo="''${repo%/}"
    name=$(${pkgs.coreutils}/bin/basename "$repo")
    safe_name=$(printf '%s' "$name" | ${pkgs.coreutils}/bin/tr -c 'A-Za-z0-9._-' '_')
    last_pull_file="$DATA_DIR/.last-pull-$safe_name"
    last_pull=0

    if [ -f "$last_pull_file" ]; then
      read -r last_pull < "$last_pull_file" || true
    fi

    case "$last_pull" in
      ""|*[!0-9]*) last_pull=0 ;;
    esac

    if [ $((now - last_pull)) -ge "$PULL_INTERVAL" ]; then
      stashed=0

      if repo_has_changes "$repo"; then
        ${pkgs.git}/bin/git -C "$repo" stash push --include-untracked || continue
        stashed=1
      fi

      ${pkgs.git}/bin/git -C "$repo" pull --rebase || continue

      if [ "$stashed" -eq 1 ]; then
        ${pkgs.git}/bin/git -C "$repo" stash pop || continue
      fi

      printf '%s\n' "$now" > "$last_pull_file"
    fi

    if repo_has_changes "$repo"; then
      newest=$(${pkgs.findutils}/bin/find "$repo" -path "$repo/.git" -prune -o -type f -printf '%T@\n' 2>/dev/null | ${pkgs.coreutils}/bin/sort -rn | ${pkgs.coreutils}/bin/head -n 1) || true
      newest_int="''${newest%%.*}"

      if [ -z "$newest_int" ] || [ $((now - newest_int)) -lt "$IDLE_THRESHOLD" ]; then
        continue
      fi

      ${pkgs.git}/bin/git -C "$repo" add -A || continue
      ${pkgs.git}/bin/git -C "$repo" diff --cached --quiet && continue
      ${pkgs.git}/bin/git -C "$repo" commit -m "$(${pkgs.coreutils}/bin/date -u +"docs(%Y/%m/%d): automatic OpenSpec backup")" || continue
      ${pkgs.git}/bin/git -C "$repo" push || true
    fi
  done
''
