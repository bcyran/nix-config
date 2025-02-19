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
}
