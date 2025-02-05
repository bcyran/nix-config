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
    address = [(mkCidr peers.homelab.ip 24)];
    privateKeyFile = config.sops.secrets.wireguard_private_key.path;
    peers = [
      {
        inherit (wireguard) endpoint;
        inherit (peers.vps) publicKey;
        allowedIPs = [wireguard.subnet];
        persistentKeepalive = 25;
      }
    ];
  };
}
