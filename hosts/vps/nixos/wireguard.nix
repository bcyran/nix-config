{
  config,
  my,
  ...
}: let
  inherit (my.lib.network) mkCidr;
  inherit (my.lib.const) wg;
  inherit (wg) peers;
  inherit (my.lib.const.lan) devices;
in {
  sops.secrets = {
    wireguard_private_key = {};
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking = {
    firewall.allowedUDPPorts = [wg.port];
    wg-quick.interfaces = {
      wg0 = {
        address = [(mkCidr peers.vps.ip 24)];
        listenPort = wg.port;
        privateKeyFile = config.sops.secrets.wireguard_private_key.path;
        dns = [devices.homelab.ip "1.1.1.1"];
        peers = [
          # Homelab
          {
            inherit (peers.homelab) publicKey;
            allowedIPs = [
              (mkCidr peers.homelab.ip 32)
              (mkCidr devices.homelab.ip 32)
            ];
          }
          # Pixel
          {
            inherit (peers.pixel7) publicKey;
            allowedIPs = [
              (mkCidr peers.pixel7.ip 32)
            ];
          }
          # Slimbook
          {
            inherit (peers.slimbook) publicKey;
            allowedIPs = [
              (mkCidr peers.slimbook.ip 32)
            ];
          }
        ];
      };
    };
  };
}
