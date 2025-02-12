{lib, ...}: {
  mkReverseProxy = serviceCfg: let
    reverseProxyHost = {
      ${serviceCfg.reverseProxy.domain} = {
        upstreamAddress = serviceCfg.address;
        upstreamPort = serviceCfg.port;
        inherit (serviceCfg.reverseProxy) listenAddress;
      };
    };
  in
    lib.mkIf (serviceCfg.reverseProxy.domain != null) reverseProxyHost;
}
