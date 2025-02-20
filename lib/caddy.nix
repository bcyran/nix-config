{lib, ...}: {
  mkReverseProxy = serviceCfg: let
    reverseProxyHost = {
      ${serviceCfg.reverseProxy.domain} = {
        upstreamAddress = serviceCfg.address;
        upstreamPort = serviceCfg.port;
        inherit (serviceCfg.reverseProxy) listenAddresses;
      };
    };
  in
    lib.mkIf (serviceCfg.reverseProxy.domain != null) reverseProxyHost;

  mkLogConfig = domain: ''
    output file /var/log/caddy/access-${domain}.log {
      roll_size 100MiB
      roll_keep 5
      roll_keep_for 2160h
      mode 644
    }
  '';
}
