{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.tailscale;
in {
  options.my.services.tailscale.enable = lib.mkEnableOption "tailscale";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.tailscale];
    services.tailscale.enable = true;
  };
}
