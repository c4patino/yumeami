{ pkgs, ... }: pkgs.writeShellScriptBin  "scratchpad" ''
    workspace_name="magic"
    cmd="kitty"

    windows=$(hyprctl clients -j | jq ".[] | select(.workspace.name == \"special:$workspace_name\")")

    if [ -z "$windows" ]; then
        hyprctl dispatch "exec [workspace special:$workspace_name] $cmd"
    else
        hyprctl dispatch togglespecialworkspace "$workspace_name"
    fi
''

