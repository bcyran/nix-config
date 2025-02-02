{config, ...}: {
  sops.secrets = {
    wireguard_private_key = {};
  };

  networking.wg-quick.interfaces.wg0 = {
    address = ["10.100.200.100/24"];
    privateKeyFile = config.sops.secrets.wireguard_private_key.path;
    peers = [
      {
        endpoint = "202.61.241.227:51820";
        publicKey = "8MAr05mDT16BYab0SBG9C8Muulvbibu1osFJTNZzRw8=";
        allowedIPs = ["10.100.200.0/24"];
        persistentKeepalive = 25;
      }
    ];
  };
}
