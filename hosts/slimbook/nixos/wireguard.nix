{
  config,
  my,
  ...
}: let
  inherit (my.lib.nm) mkWireguardProfile;
  inherit (my.lib.network) mkCidr;
  inherit (my.lib.const) wireguard;
  inherit (wireguard) peers;
  inherit (my.lib.const.lan) devices;
in {
  sops.secrets = {
    wireguard_env_file = {};
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = with config.sops.secrets; [
      wireguard_env_file.path
    ];
    profiles = {
      vps = mkWireguardProfile {
        id = "vps";
        interfaceName = "wg0";
        address = mkCidr peers.slimbook.ip 24;
        privateKey = "$WIREGUARD_PRIVATE_KEY";
        peerEndpoint = wireguard.endpoint;
        peerPublicKey = peers.vps.publicKey;
        peerAllowedIPs = [
          wireguard.subnet
          (mkCidr devices.homelab.ip 32)
        ];
      };
    };
  };
}
