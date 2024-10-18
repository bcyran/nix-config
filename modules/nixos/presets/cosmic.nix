{
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
  cfg = config.my.presets.cosmic;
in {
  options.my.presets.cosmic.enable = lib.mkEnableOption "cosmic";

  config = lib.mkIf cfg.enable {
    # Binary cache for COSMIC
    nix.settings = {
      substituters = ["https://cosmic.cachix.org/"];
      trusted-public-keys = ["cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="];
    };

    # Enable COSMIC
    services = {
      desktopManager.cosmic.enable = true;
      displayManager.cosmic-greeter.enable = true;
    };
  };
}
