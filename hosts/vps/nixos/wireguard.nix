{config, ...}: {
  sops.secrets = {
    wireguard_private_key = {};
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking = {
    firewall.allowedUDPPorts = [51820];
    wg-quick.interfaces = {
      wg0 = {
        address = ["10.100.200.1/24"];
        listenPort = 51820;
        privateKeyFile = config.sops.secrets.wireguard_private_key.path;
        dns = ["10.100.100.100"];
        peers = [
          # Homelab
          {
            publicKey = "hHCFLo07K0hlVbFfRA4Q4iy8qHSusK81732k/Rt2ZCM=";
            allowedIPs = [
              "10.100.200.100/24" # Wireguard subnet
              "10.100.100.100/32" # Homelab
            ];
          }
          # Pixel
          {
            publicKey = "SQIXPzLluN+Ji7s3Wzau59dzlOjebd6TxRbGm8vtDho=";
            allowedIPs = [
              "10.100.200.2/32" # Pixel
            ];
          }
        ];
      };
    };
  };
}
