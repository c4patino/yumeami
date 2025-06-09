{lib, ...}:
with lib; rec {
  ## Create a NixOS module option.
  ##
  ## ```nix
  ## lib.mkOpt nixpkgs.lib.types.str "My default" "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkOpt = type: default: description:
    mkOption {inherit type default description;};

  ## Create a NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkOpt' nixpkgs.lib.types.str "My default"
  ## ```
  ##
  #@ Type -> Any -> String
  mkOpt' = type: default: mkOpt type default null;

  ## Create a boolean NixOS module option.
  ##
  ## ```nix
  ## lib.mkBoolOpt true "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkBoolOpt = mkOpt types.bool;

  ## Create a boolean NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkBoolOpt true
  ## ```
  ##
  #@ Type -> Any -> String
  mkBoolOpt' = mkOpt' types.bool;

  ## Quickly enable an option.
  ##
  ## ```nix
  ## services.nginx = enabled;
  ## ```
  ##
  #@ true
  enabled = {
    enable = true;
  };

  ## Quickly disable an option.
  ##
  ## ```nix
  ## services.nginx = enabled;
  ## ```
  ##
  #@ false
  disabled = {
    enable = false;
  };

  ## Recursively nest an attribute set under a list of keys.
  ##
  ## For example:
  ## ```nix
  ## mkNestedAttrs { enable = true; } [ "foo" "bar" ]
  ## ```
  ## returns:
  ## ```nix
  ## { foo = { bar = { enable = true; }; }; }
  ## ```
  ##
  ## @param attrs Attribute set to nest.
  ## @param keys  List of keys (strings) to nest under.
  ## @return Nested attribute set.
  mkNestedAttrs = attrs: keys:
    if keys == []
    then attrs
    else {
      "${lib.head keys}" = mkNestedAttrs attrs (lib.tail keys);
    };

  ## Nest an attribute set under a dot-separated namespace string.
  ##
  ## For example:
  ## ```nix
  ## mkOptionsWithNamespace "foo.bar" { enable = true; }
  ## ```
  ## returns:
  ## ```nix
  ## { foo = { bar = { enable = true; }; }; }
  ## ```
  ##
  ## @param namespace       A string like "foo.bar.baz".
  ## @param options         An attribute set to nest under the namespace.
  ## @return                A nested attribute set.
  mkOptionsWithNamespace = namespace: options:
    namespace
    |> splitString "."
    |> mkNestedAttrs options;

  ## Get a deeply nested attribute from a dot-separated path string.
  ##
  ## For example:
  ## ```nix
  ## getAttrByNamespace "foo.bar.baz" config
  ## ```
  ## is equivalent to:
  ## ```nix
  ## lib.getAttrFromPath [ "foo" "bar" "baz" ] config
  ## ```
  ##
  ## @param set       The attribute set to query.
  ## @param namespace Dot-separated string path.
  ## @return          The value at the nested path.
  getAttrByNamespace = set: namespace:
    namespace
    |> splitString "."
    |> (path: getAttrFromPath path set);

  ## Resolve the IP address of a given host from a devices attribute set.
  ##
  ## @param devices A set mapping hostnames to their configuration (must include `IP`).
  ## @param node    The hostname to resolve.
  ## @return        The IP address for the given node.
  ## @throws        If the node is not defined in the devices set.
  resolveHostIP = devices: node:
    if builtins.hasAttr node devices
    then devices.${node}.IP
    else builtins.throw "Host '${node}' does not exist in the devices configuration.";

  ## Check for configuration conflicts between mount and share declarations.
  ##
  ## @param shares   A list of folder names that are shared.
  ## @param hostName The name of the current host.
  ## @param folder   The folder being mounted or shared.
  ## @param host     The host the folder is being mounted from.
  ## @return         Null if valid; throws an error if a conflict is detected.
  ## @throws         If the host is self-mounting or if the folder appears in both shares and mounts.
  checkHostMountConflict = {
    shares,
    hostName,
  }: folder: host:
    if host == hostName
    then throw "Conflict: Mount host '${host}' cannot be the same as this host '${hostName}' for folder '${folder}'."
    else if builtins.elem folder shares
    then throw "Conflict: Folder '${folder}' is listed in both shares and mounts. Please resolve."
    else null;

  ## Attempt to read a JSON file and return null of not valid JSON.
  ##
  ## @param path  path to the json file to read
  ##
  ## @return      JSON if valid; returns {} if invalid JSON.
  readJsonOrEmpty = path: let
    result =
      path
      |> builtins.readFile
      |> builtins.fromJSON
      |> builtins.tryEval;
  in
    if result.success
    then result.value
    else {};

  ## Safe get for deeply nested keys
  ##
  ## @param pathStr   dot-separated list for the nested attribute to retrieve
  ## @param attrs     attribute list for getting the keys
  ## @return          attribute value if found; otherwise null
  getIn = pathStr: attrs: let
    path = splitString "." pathStr;
    go = attrs: p:
      if p == []
      then attrs
      else let
        key = builtins.head p;
        rest = builtins.tail p;
      in
        if builtins.hasAttr key attrs
        then go (attrs.${key}) rest
        else null;
  in
    go attrs path;
}
