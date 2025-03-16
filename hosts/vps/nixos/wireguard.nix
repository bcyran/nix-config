{
  config,
  my,
  ...
}: let
  inherit (my.lib.network) mkCidr;
  inherit (my.lib.const) wireguard dns;
  inherit (wireguard) peers;
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
    firewall.allowedUDPPorts = [wireguard.port];
    wg-quick.interfaces = {
      wg0 = {
        address = [
          (mkCidr peers.vps.ip 24)
          (mkCidr peers.vps.ipv6 80)
        ];
        listenPort = wireguard.port;
        privateKeyFile = config.sops.secrets.wireguard_private_key.path;
        dns =
          [
            devices.homelab.ip
            peers.homelab.ipv6
          ]
          ++ dns.ips;
        peers = [
          # Homelab
          {
            inherit (peers.homelab) publicKey;
            allowedIPs = [
              (mkCidr peers.homelab.ip 32)
              (mkCidr peers.homelab.ipv6 128)
              (mkCidr devices.homelab.ip 32)
            ];
          }
          # Pixel
          {
            inherit (peers.pixel7) publicKey;
            allowedIPs = [
              (mkCidr peers.pixel7.ip 32)
              (mkCidr peers.pixel7.ipv6 128)
            ];
          }
          # Slimbook
          {
            inherit (peers.slimbook) publicKey;
            allowedIPs = [
              (mkCidr peers.slimbook.ip 32)
              (mkCidr peers.slimbook.ipv6 128)
            ];
          }
          # Client #1
          {
            publicKey = "cDl6OrK4BWgZxkIyNx4JE/W8UHrgHfrZwunGLlEoO3E=";
            allowedIPs = [
              "10.100.200.200/32"
              "2a03:4000:52:499:ffff::200/128"
            ];
          }
        ];
      };
    };
  };
}
