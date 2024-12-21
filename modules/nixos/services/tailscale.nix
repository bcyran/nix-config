{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.tailscale;
in {
  options.my.services.tailscale = {
    enable = lib.mkEnableOption "tailscale";

    authKeyFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "Path to the Tailscale authentication key file.";
    };

    advertiseRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Routes to expose to the Tailscale network.";
      example = ["192.168.0.100/32"];
    };
  };

  config =
    lib.mkIf cfg.enable
    {
      environment.systemPackages = [pkgs.tailscale];

      services.tailscale = let
        advertiseRoutesEnabled = cfg.advertiseRoutes != [];
      in {
        enable = true;
        inherit (cfg) authKeyFile;
        useRoutingFeatures =
          if advertiseRoutesEnabled
          then "server"
          else "none";
        extraUpFlags = lib.mkIf advertiseRoutesEnabled [
          "--accept-dns=false"
          "--advertise-routes ${lib.concatStringsSep "," cfg.advertiseRoutes}"
        ];
      };
    };
}
