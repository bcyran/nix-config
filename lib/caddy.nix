{lib, ...}: rec {
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
        logFormat = mkLogConfig domain;
      };
    };
  in
    lib.mkIf (domain != null) virtualHostConfig;

  mkLogConfig = domain: ''
    output file /var/log/caddy/access-${domain}.log {
      roll_size 100MiB
      roll_keep 5
      roll_keep_for 2160h
      mode 644
    }
  '';
}
