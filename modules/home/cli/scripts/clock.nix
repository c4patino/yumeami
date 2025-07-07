{pkgs, ...}:
pkgs.writeShellScriptBin "clock" ''
  ${pkgs.tty-clock}/bin/tty-clock -c -C 6 -s
''
