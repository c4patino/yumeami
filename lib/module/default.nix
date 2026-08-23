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

  ## Create a required NixOS module option (no default).
  ##
  ## ```nix
  ## lib.mkRequiredOpt nixpkgs.lib.types.str "Description of my option."
  ## ```
  ##
  #@ Type -> String -> Option
  mkRequiredOpt = type: description:
    mkOption {
      inherit type description;
      default = null;
    };

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

  ## Create a nullable NixOS module option.
  ##
  ## ```nix
  ## lib.mkNullableOpt types.str null "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkNullableOpt = type: default: description:
    mkOpt (types.nullOr type) default description;

  ## Create a nullable NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkNullableOpt' types.str null
  ## ```
  ##
  #@ Type -> Any -> String
  mkNullableOpt' = type: default: mkNullableOpt type default null;

  ## Create an attrsOf NixOS module option.
  ##
  ## ```nix
  ## lib.mkOptAttrset types.str {} "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkOptAttrset = type: default: description:
    mkOpt (types.attrsOf type) default description;

  ## Create an attrsOf NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkOptAttrset' types.str {}
  ## ```
  ##
  #@ Type -> Any -> String
  mkOptAttrset' = type: default: mkOptAttrset type default null;

  ## Create a store path that symlinks to a path outside the Nix store.
  ##
  ## This is useful for mutable/decrypted files that should not be copied into
  ## the store, matching Home Manager's mkOutOfStoreSymlink behavior.
  mkOutOfStoreSymlink = pkgs: path:
    pkgs.runCommandLocal "${baseNameOf path}" {} ''
      ln -s ${lib.escapeShellArg path} $out
    '';

  ## Create a listOf NixOS module option.
  ##
  ## ```nix
  ## lib.mkListOpt types.str [] "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkListOpt = type: default: description:
    mkOpt (types.listOf type) default description;

  ## Create a listOf NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkListOpt' types.str []
  ## ```
  ##
  #@ Type -> Any -> String
  mkListOpt' = type: default: mkListOpt type default null;

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
    then devices.${node}.ip
    else throw "Host '${node}' does not exist in the devices configuration.";

  ## Return whether a given host is a gateway from a devices attribute set.
  ##
  ## @param devices A set mapping hostnames to their configuration (must include `IP`).
  ## @param node    The hostname to resolve.
  ## @return        The IP address for the given node.
  ## @throws        If the node is not defined in the devices set.
  isGateway = devices: node:
    if builtins.hasAttr node devices
    then devices.${node}.gateway
    else false;

  ## Resolve the hostname of the gateway from a devices attribute set.
  ##
  ## ```nix
  ## devices |> resolveGatewayHost
  ## ```
  ##
  ## @param devices A set mapping hostnames to their configuration.
  ## @return        The hostname of the declared gateway.
  ## @throws        If no gateway is declared or multiple gateways exist.
  resolveGatewayHost = devices: let
    gateways =
      devices
      |> filterAttrs (_: dev: dev.gateway or false)
      |> attrNames;
  in
    if gateways == []
    then throw "No gateway device declared in the devices configuration."
    else if length gateways > 1
    then throw "Multiple gateway devices declared: ${concatStringsSep ", " gateways}."
    else head gateways;

  ## Resolve the hostname that hosts a specific database.
  ##
  ## @param databases A set mapping hostnames to lists of database names.
  ## @param dbName    The name of the database to find.
  ## @return          The hostname where the database is hosted.
  ## @throws          If no host is found for the given database.
  resolveDatabaseHost = databases: dbName: let
    matchingHosts =
      databases
      |> filterAttrs (host: dbs: lib.elem dbName dbs)
      |> attrNames;
  in
    if matchingHosts == []
    then throw "No host found for database '${dbName}'."
    else builtins.head matchingHosts;

  ## Resolve the IP address of the host that hosts a specific database.
  ##
  ## @param devices   A set mapping hostnames to their configuration (must include `ip`).
  ## @param databases A set mapping hostnames to lists of database names.
  ## @param dbName    The name of the database to find.
  ## @return          The IP address of the host where the database is hosted.
  ## @throws          If no host is found for the given database.
  resolveDatabaseIP = devices: databases: dbName:
    resolveHostIP devices (resolveDatabaseHost databases dbName);

  ## Generate systemd `wants` and `after` ordering so a unit starts only once
  ## the network stack is online and the Tailscale mesh is up. Services that
  ## dial other hosts via their `100.x` Tailscale address must wait on
  ## `tailscaled.service`, which itself only starts after
  ## `NetworkManager-wait-online.service`, i.e. after `network-online.target`.
  ##
  ## Reference as a unit attribute set in `systemd.services.<name>`, e.g.
  ## `waitForNetwork // { serviceConfig = {...}; }`.
  ##
  #@ AttrSet
  waitForNetwork = {
    wants = ["network-online.target" "tailscaled.service"];
    after = ["network-online.target" "tailscaled.service"];
  };

  ## Check for configuration conflicts between mount and share declarations.
  ##
  ## @param shares    A list of folder names that are shared.
  ## @param hostName  The name of the current host.
  ## @param folder    The folder being mounted or shared.
  ## @param host      The host the folder is being mounted from.
  ## @return          Null if valid; throws an error if a conflict is detected.
  ## @throws          If the host is self-mounting or if the folder appears in both shares and mounts.
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

  ## Collect every declaration of a service across all hosts, ordered by
  ## precedence: lowest `priority` first; ties break alphabetically by hostname.
  ##
  ## ```nix
  ## networkServices |> resolveServiceEntries "unbound"
  ## ```
  ##
  ## @param serviceName     The name of the service.
  ## @param networkServices The network-services attribute set (host-first shape).
  ## @return                Ordered list of `{ host, priority, ...serviceAttrs }`.
  resolveServiceEntries = serviceName: networkServices:
    networkServices
    |> filterAttrs (_: svcs: svcs ? ${serviceName})
    |> mapAttrsToList (host: svcs:
      svcs.${serviceName}
      // {
        inherit host;
        priority = svcs.${serviceName}.priority or 100;
      })
    |> sort (a: b:
      a.priority
      < b.priority
      || (a.priority == b.priority && a.host < b.host));

  ## Convert a host-first service map into a flat service->attrs map.
  ##
  ## Input:  { hostName = { serviceName = { ... }; ... }; ... }
  ## Output: { serviceName = { host = hostName; priority = n; ... }; ... }
  ##
  ## When several hosts declare the same service, the entry with the lowest
  ## `priority` wins; ties break alphabetically by hostname.
  ##
  ## @param hostServices  Attribute set mapping host names to their service maps.
  ## @return              Flattened map with service names as keys, augmented with host.
  flattenHostServices = hostServices: let
    serviceNames =
      hostServices
      |> mapAttrsToList (_: svcs: attrNames svcs)
      |> concatLists
      |> unique;

    primaries =
      serviceNames
      |> map (svcName: {
        name = svcName;
        value = builtins.head (resolveServiceEntries svcName hostServices);
      })
      |> listToAttrs;
  in
    primaries;

  ## Resolve every host that declares a given service, in order of precedence.
  ##
  ## Hosts are sorted by the service's `priority` (lower first); ties break
  ## alphabetically by hostname.
  ##
  ## ```nix
  ## networkServices |> resolveServiceHosts "unbound"
  ## ```
  ##
  ## @param serviceName     The name of the service.
  ## @param networkServices The network-services attribute set (host-first shape).
  ## @return                Ordered list of hostnames declaring the service.
  resolveServiceHosts = serviceName: networkServices:
    resolveServiceEntries serviceName networkServices
    |> map (entry: entry.host);

  ## Check if a host has a specific service defined in the network-services config.
  ##
  ## @param networkServices The network-services attribute set (host-first shape).
  ## @param hostName         The hostname to check.
  ## @param serviceName      The name of the service to check for.
  ## @return                 true if the host has the specific service defined, false otherwise.
  hostHasService = networkServices: hostName: serviceName:
    networkServices ? ${hostName}
    && networkServices.${hostName} ? ${serviceName};

  ## Resolve the port of the highest-precedence instance of a service.
  ##
  ## With multiple hosts declaring the same service, the instance on the host
  ## with the lowest `priority` wins (ties break alphabetically by hostname).
  ##
  ## @param networkServices The network-services attribute set (host-first shape).
  ## @param serviceName     The name of the service.
  ## @param defaultPort     The default port to use if not specified in network-services.
  ## @return               The port (either from config or default).
  ## @throws               If no host declares the given service.
  resolveServicePort = networkServices: serviceName: defaultPort: let
    entries = resolveServiceEntries serviceName networkServices;
  in
    if entries == []
    then throw "No host declares service '${serviceName}'."
    else (builtins.head entries).port or defaultPort;

  ## Resolve the host of the highest-precedence instance of a service.
  ##
  ## With multiple hosts declaring the same service, the host with the lowest
  ## `priority` wins (ties break alphabetically by hostname).
  ##
  ## @param networkServices The network-services attribute set (host-first shape).
  ## @param serviceName     The name of the service.
  ## @return                The host name where the primary instance is declared.
  ## @throws                If no host declares the given service.
  resolveServiceHost = networkServices: serviceName: let
    entries = resolveServiceEntries serviceName networkServices;
  in
    if entries == []
    then throw "No host declares service '${serviceName}'."
    else (builtins.head entries).host;

  ## Create an impermanence persistence directory owned by a service user.
  ##
  ## ```nix
  ## mkPersistDir config "forgejo" "/var/lib/forgejo" "700"
  ## ```
  ##
  ## @param config    The module config (passed from the module).
  ## @param username  The service username (must exist in config.users.users).
  ## @param directory The directory path to persist.
  ## @param mode      The directory permission mode (e.g. "700").
  ## @return An attrset for the impermanence.folders list.
  mkPersistDir = config: username: directory: mode: let
    u = config.users.users.${username};
  in {
    inherit directory;
    user = u.name;
    group = u.group;
    inherit mode;
  };

  ## Create an impermanence persistence directory owned by root.
  ##
  ## ```nix
  ## mkPersistRootDir config "/var/lib/docker" "700"
  ## ```
  ##
  ## @param config    The module config (passed from the module).
  ## @param directory The directory path to persist.
  ## @param mode      The directory permission mode (e.g. "700").
  ## @return An attrset for the impermanence.folders list.
  mkPersistRootDir = config: directory: mode: mkPersistDir config "root" directory mode;
}
