{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.configurations.vpnConfinement;

  # Shamelessly copied from:
  # https://github.com/rasmus-kirk/nixarr/blob/main/nixarr/default.nix#L282C6-L322C37.
  vpnTestScript = pkgs.writeShellApplication {
    name = "vpn-test";
    runtimeInputs = with pkgs; [util-linux unixtools.ping coreutils curl bash libressl netcat-gnu openresolv dig];
    text = ''
      cd "$(mktemp -d)"

      # DNS information
      dig google.com

      # Print resolv.conf
      echo "/etc/resolv.conf contains:"
      cat /etc/resolv.conf

      # Query resolvconf
      echo "resolvconf output:"
      resolvconf -l
      echo ""

      # Get ip
      echo "Getting IP:"
      curl -s ipinfo.io

      echo -ne "DNS leak test:"
      curl -s https://raw.githubusercontent.com/macvk/dnsleaktest/b03ab54d574adbe322ca48cbcb0523be720ad38d/dnsleaktest.sh -o dnsleaktest.sh
      chmod +x dnsleaktest.sh
      ./dnsleaktest.sh
    '';
  };
in {
  options.my.configurations.vpnConfinement = let
    serviceName = "VPN confinement";
  in {
    enable = lib.mkEnableOption serviceName;

    wireguardConfigFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/path/to/wg.conf";
      description = "The path to the WireGuard configuration file.";
    };

    namespaceName = lib.mkOption {
      type = lib.types.str;
      default = "wg1";
      example = "proton";
      description = "The name of the VPN namespace.";
    };

    allowedEgress = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["10.0.0.0/8" "192.168.1.50"];
      description = ''
        Subnets, ranges, and specific addresses that services inside the VPN
        namespace may initiate new outgoing connections to outside the VPN
        tunnel, e.g. a download client running on the host or LAN. Without
        this, the namespace's kill switch drops any new outgoing connection
        to destinations that aren't listed here.

        Note: "127.0.0.1" cannot be used to reach a host-side service this
        way. The kernel always routes the entire 127.0.0.0/8 range to the
        namespace's own loopback interface, regardless of any custom routes,
        so traffic to it never actually leaves the namespace. Use a real,
        routable host/LAN address instead (e.g. via a reverse proxy).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> cfg.wireguardConfigFile != null;
        message = ''
          my.configurations.vpnConfinement.wireguardConfigFile must be set when
          my.configurations.vpnConfinement.enable is true.
        '';
      }
    ];

    vpnNamespaces.${cfg.namespaceName} = {
      enable = true;
      inherit (cfg) wireguardConfigFile;

      accessibleFrom = [
        "10.0.0.0/8"
        "127.0.0.1"
      ];

      inherit (cfg) allowedEgress;
    };

    systemd.services.vpn-test-service = {
      enable = true;
      description = "VPN test service";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${vpnTestScript}/bin/vpn-test";
      };
      wantedBy = ["multi-user.target"];
      after = ["${cfg.namespaceName}.service"];
      vpnConfinement = {
        enable = true;
        vpnNamespace = cfg.namespaceName;
      };
    };
  };
}
