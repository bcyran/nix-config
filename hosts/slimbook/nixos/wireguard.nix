{
  config,
  my,
  ...
}: {
  sops.secrets = {
    wireguard_env_file = {};
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = with config.sops.secrets; [
      wireguard_env_file.path
    ];
    profiles = {
      vps = my.lib.nm.mkWireguardProfile {
        id = "vps";
        interfaceName = "wg0";
        address = "10.100.200.3";
        privateKey = "$WIREGUARD_PRIVATE_KEY";
        peerEndpoint = "vps.cyran.dev:51820";
        peerPublicKey = "8MAr05mDT16BYab0SBG9C8Muulvbibu1osFJTNZzRw8=";
        peerAllowedIPs = "10.100.200.0/24;10.100.100.100/32;";
      };
    };
  };
}
