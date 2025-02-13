# Helpers for generating NetworkManager profiles.
{lib, ...}: {
  # Creates a NetworkManager profile for a WiFi connection.
  mkWifiProfile = {
    id,
    ssid,
    psk,
    autoconnect ? true,
  }: {
    connection = {
      inherit id autoconnect;
      type = "wifi";
    };
    wifi = {
      inherit ssid;
      mode = "infrastructure";
    };
    wifi-security = {
      inherit psk;
      auth-alg = "open";
      key-mgmt = "wpa-psk";
    };
    ipv4 = {
      method = "auto";
    };
    ipv6 = {
      method = "auto";
      addr-gen-mode = "default";
    };
  };

  # Creates a NetworkManager profile for a WireGuard VPN connection.
  mkWireguardProfile = {
    id,
    interfaceName,
    address,
    dns ? null,
    addressv6 ? null,
    dnsv6 ? null,
    privateKey,
    peerEndpoint,
    peerPublicKey,
    peerAllowedIPs,
    autoconnect ? false,
  }: {
    connection = {
      inherit id autoconnect;
      type = "wireguard";
      interface-name = interfaceName;
    };
    wireguard = {
      private-key = privateKey;
    };
    "wireguard-peer.${peerPublicKey}" = {
      endpoint = peerEndpoint;
      allowed-ips = builtins.concatStringsSep ";" peerAllowedIPs;
    };
    ipv4 =
      {
        inherit address;
        method = "manual";
      }
      // lib.optionalAttrs (dns != null) {inherit dns;};
    ipv6 =
      if (addressv6 != null)
      then
        {
          address = addressv6;
          method = "manual";
        }
        // lib.optionalAttrs (dnsv6 != null) {dns = dnsv6;}
      else {
        addr-gen-mode = "default";
        method = "disabled";
      };
    proxy = {};
  };
}
