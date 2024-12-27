{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.blocky;
in {
  options.my.services.blocky = {
    enable = lib.mkEnableOption "blocky";

    customDNSMappings = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = {};
      description = "Custom DNS mappings.";
    };

    dnsPort = lib.mkOption {
      type = lib.types.int;
      default = 53;
      description = "The port on which the DNS server listens.";
    };
    httpPort = lib.mkOption {
      type = lib.types.int;
      default = 4000;
      description = "The port on which the HTTP server listens.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [cfg.dnsPort];
      allowedUDPPorts = [cfg.dnsPort];
    };

    services.blocky = {
      enable = true;
      settings = {
        ports = {
          dns = cfg.dnsPort;
          http = cfg.httpPort;
        };
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
        customDNS.mapping = cfg.customDNSMappings;
        prometheus.enable = true;
      };
    };
  };
}
