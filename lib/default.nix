{}: {
  resolveHostIP = devices: node:
    if builtins.hasAttr node devices
    then devices.${node}.IP
    else builtins.throw "Host '${node}' does not exist in the devices configuration.";

  checkHostConflict = {
    shares,
    hostName,
  }: folder: host:
    if host == hostName
    then throw "Conflict: Mount host '${host}' cannot be the same as this host '${hostName}' for folder '${folder}'."
    else if builtins.elem folder shares
    then throw "Conflict: Folder '${folder}' is listed in both shares and mounts. Please resolve."
    else null;
}
