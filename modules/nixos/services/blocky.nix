{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.blocky;
in {
  options.my.services.blocky = {
    enable = lib.mkEnableOption "blocky";

    port = lib.mkOption {
      type = lib.types.int;
      default = 53;
      description = "The port on which the DNS server listens.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [cfg.port];
      allowedUDPPorts = [cfg.port];
    };

    services.blocky = {
      enable = true;
      settings = {
        ports.dns = cfg.port;
        upstreams.groups.default = [
          "https://cloudflare-dns.com/dns-query"
        ];
        bootstrapDns = {
          upstream = "https://cloudflare-dns.com/dns-query";
          ips = ["1.1.1.1" "1.0.0.1"];
        };
        blocking = {
          denylists = {
            ads = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            ];
          };
          clientGroupsBlock = {
            default = ["ads"];
          };
        };
        caching = {
          minTime = "5m";
          maxTime = "30m";
          prefetching = true;
        };
      };
    };
  };
}
