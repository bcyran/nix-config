# Helpers for generating NetworkManager profiles.
{
  # mkWifiProfile  :: { id, ssid, psk } -> attrs
  #
  # Returns a NetworkManager profile for a WiFi connection with the given `id`, `ssid`, and `psk`.
  mkWifiProfile = {
    id,
    ssid,
    psk,
  }: {
    connection = {
      inherit id;
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

  # mkWireguardProfile  :: { id, interfaceName, address, privateKey, peerEndpoint, peerPublicKey, peerAlloweeIPs } -> attrs
  #
  # Returns a NetworkManager profile for a WireGuard connection.
  mkWireguardProfile = {
    id,
    interfaceName,
    address,
    privateKey,
    peerEndpoint,
    peerPublicKey,
    peerAllowedIPs,
  }: {
    connection = {
      inherit id;
      type = "wireguard";
      interface-name = interfaceName;
    };
    wireguard = {
      private-key = privateKey;
    };
    "wireguard-peer.${peerPublicKey}" = {
      endpoint = peerEndpoint;
      allowed-ips = peerAllowedIPs;
    };
    ipv4 = {
      inherit address;
      method = "manual";
    };
    ipv6 = {
      addr-gen-mode = "default";
      method = "disabled";
    };
    proxy = {};
  };
}
