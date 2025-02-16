{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.nix-serve;
in {
  options.my.services.nix-serve = let
    serviceName = "Uptime Kuma";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 5000;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;

    secretKeyFile = lib.mkOption {
      type = lib.types.path;
      example = "/run/secrets/nix-serve-secret-key";
      description = "Path to the nix store binary cache key file.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nix-serve = {
      enable = true;
      bindAddress = cfg.address;
      inherit (cfg) port openFirewall secretKeyFile;
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
