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
    profiles = let
      vpsProfileCommon = {
        interfaceName = "wg0";
        address = mkCidr peers.slimbook.ip 24;
        addressv6 = mkCidr peers.slimbook.ipv6 80;
        privateKey = "$WIREGUARD_PRIVATE_KEY";
        peerEndpoint = wireguard.endpoint;
        peerPublicKey = peers.vps.publicKey;
      };
    in {
      # Connection for when I'm inside my home LAN.
      # Only wireguard subnet is routed through the tunnel.
      vps-inside = mkWireguardProfile ({
          id = "vps-inside";
          peerAllowedIPs = [
            wireguard.subnet
            wireguard.subnetv6
          ];
        }
        // vpsProfileCommon);
      # Connection for when I'm outside my home LAN.
      # Additionally to the wireguard subnet, homelab connection is routed through the tunnel as well.
      # This way I can access my homelab using its LAN IP, like I'm at home.
      vps-outside = mkWireguardProfile ({
          id = "vps-outside";
          peerAllowedIPs = [
            wireguard.subnet
            wireguard.subnetv6
            (mkCidr devices.homelab.ip 32)
          ];
        }
        // vpsProfileCommon);
    };
  };
}
