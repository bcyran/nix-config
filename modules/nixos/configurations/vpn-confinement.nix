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
        "192.168.1.0/24"
        "10.0.0.0/8"
        "127.0.0.1"
      ];
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
