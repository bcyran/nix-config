{
  config,
  my,
  ...
}: let
  inherit (my.lib.network) mkCidr;
  inherit (my.lib.const) wireguard;
  inherit (wireguard) peers;
in {
  sops.secrets = {
    wireguard_private_key = {};
  };

  networking.wg-quick.interfaces.wg0 = {
    address = [
      (mkCidr peers.homelab.ip 24)
      (mkCidr peers.homelab.ipv6 80)
    ];
    privateKeyFile = config.sops.secrets.wireguard_private_key.path;
    peers = [
      {
        inherit (wireguard) endpoint;
        inherit (peers.vps) publicKey;
        allowedIPs = [
          wireguard.subnet
          wireguard.subnetv6
        ];
        persistentKeepalive = 25;
      }
    ];
  };
  # Attempt to reconnect every minute without limit if the connection drops.
  systemd.services.wg-quick-wg0.serviceConfig = {
    StartLimitBurst = 0;
    Restart = "on-failure";
    RestartSec = 60;
  };
}
