{lib, ...}: {
  makeReverseProxy = {
    domain,
    address,
    port,
    proxyExtraConfig ? "",
    extraConfig ? "",
  }: let
    virtualHostConfig = {
      ${domain} = {
        extraConfig = ''
          reverse_proxy ${address}:${toString port} {
            ${proxyExtraConfig}
          }

          ${extraConfig}
        '';
        logFormat = ''
          output file /var/log/caddy/access-${domain}.log {
            roll_size 100MiB
            roll_keep 5
            roll_keep_for 2160h
            mode 644
          }
        '';
      };
    };
  in
    lib.mkIf (domain != null) virtualHostConfig;
}
