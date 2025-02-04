{
  config,
  my,
  ...
}: let
  inherit (my.lib.network) mkCidr;
  inherit (my.lib.const) wg;
  inherit (wg) peers;
in {
  sops.secrets = {
    wireguard_private_key = {};
  };

  networking.wg-quick.interfaces.wg0 = {
    address = [(mkCidr peers.homelab.ip 24)];
    privateKeyFile = config.sops.secrets.wireguard_private_key.path;
    peers = [
      {
        inherit (wg) endpoint;
        inherit (peers.vps) publicKey;
        allowedIPs = [wg.subnet];
        persistentKeepalive = 25;
      }
    ];
  };
}
