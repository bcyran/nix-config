{lib}: rec {
  # NixOS and Home Manager configuration utilities.
  config = import ./config.nix {inherit lib;};

  # forEachSystemPkgs :: [<system>] -> <nixpkgs> -> (<packages> -> <attrs>) -> <attrs>
  #
  # Generates attributes for each system in `systems` using `f` with packages for that system
  # passed as an argument.
  forEachSystemPkgs = systems: nixpkgs: f:
    nixpkgs.lib.genAttrs systems
    (system: f nixpkgs.legacyPackages.${system});

  # listDir :: path -> [string]
  #
  # Returns a list of names of files (and dirs) in the given directory.
  listDir = dir: (builtins.attrNames (builtins.readDir dir));

  # makeAbsolute :: path -> [string] -> [path]
  #
  # Returns a list of absolute paths of `children` in `parent`.
  makeAbsolute = parent: children:
    map (child: parent + "/${child}") children;

  # listDirModules :: path -> [path]
  #
  # Returns a list of absolute paths of files in `dir`, omitting `default.nix`.
  listDirModules = dir:
    makeAbsolute dir (
      builtins.filter (filename: filename != "default.nix")
      (listDir dir)
    );

  # isFalsy :: anything -> bool
  #
  # Returns true if `x` is falsy, false otherwise.
  isFalsy = x: x == false || x == null || x == "" || x == 0 || x == [] || x == {};

  # makeRequiredAssertion :: string -> string -> string -> attrs
  #
  # Returns an assertion that checks if `attrset.attr` is set (not falsy).
  makeRequiredAssertion = attrset: attrsetPath: attr: {
    assertion = !(isFalsy attrset.${attr});
    message = "Required attribute '${attrsetPath}.${attr}' is missing.";
  };

  # makeNetworkmanagerWifiProfile :: { id, ssid, psk } -> attrs
  #
  # Returns a NetworkManager profile for a WiFi connection with the given `id`, `ssid`, and `psk`.
  makeNetworkManagerWifiProfile = {
    id,
    ssid,
    psk,
  }: {
    connection = {
      inherit id;
      type = "wifi";
    };
    wifi = {
      inherit ssid;
      mode = "infrastructure";
    };
    wifi-security = {
      inherit psk;
      auth-alg = "open";
      key-mgmt = "wpa-psk";
    };
    ipv4 = {
      method = "auto";
    };
    ipv6 = {
      method = "auto";
      addr-gen-mode = "default";
    };
  };
}
