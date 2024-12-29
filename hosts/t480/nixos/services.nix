{
  inputs,
  config,
  ...
}: let
  homelabSopsFile = "${inputs.my-secrets}/homelab.yaml";

  intraIP = "192.168.0.130";
  intraDomain = "intra.cyran.dev";
in {
  sops = {
    secrets = {
      ovh_api_env_file.sopsFile = homelabSopsFile;
      tailscale_auth_key.sopsFile = homelabSopsFile;
      syncthing_key_file.sopsFile = homelabSopsFile;
      syncthing_cert_file.sopsFile = homelabSopsFile;
      homepage_env_file.sopsFile = homelabSopsFile;
      hass_secrets_file = {
        sopsFile = homelabSopsFile;
        path = "${config.services.home-assistant.configDir}/secrets.yaml";
        owner = "hass";
        restartUnits = ["home-assistant.service"];
      };
    };
  };

  my.services = {
    blocky = {
      enable = true;
      customDNSMappings = {
        ${intraDomain} = intraIP;
      };
    };
    caddy = {
      enable = true;
      environmentFiles = [config.sops.secrets.ovh_api_env_file.path];
    };
    prometheus = {
      enable = true;
      domain = "prometheus.${intraDomain}";
    };
    loki.enable = true;
    grafana = {
      enable = true;
      domain = "grafana.${intraDomain}";
    };
    tailscale = {
      enable = true;
      advertiseRoutes = ["${intraIP}/32"];
      authKeyFile = config.sops.secrets.tailscale_auth_key.path;
    };
    syncthing = {
      enable = true;
      domain = "syncthing.${intraDomain}";
      keyFile = config.sops.secrets.syncthing_key_file.path;
      certFile = config.sops.secrets.syncthing_cert_file.path;
      devices = {
        slimbook = "ADH7KVP-ATNX6XY-VSBFKEW-U7A4TAI-2YA6JQG-DZHNGRR-2DZOIXW-KAS6AQX";
        pixel7 = "WCA3ZM5-ZELYQWF-VAWS425-OPG5Q4R-O4J3ARM-IOPGI7Z-BTE2TY5-EZ36AAI";
        srv = "K755SJE-WJVQQNY-M3RSJP7-RYLNIOF-TJNMR3H-32WAY53-KPX5BFM-5RZSRQL";
      };
      folders = ["KeePass" "Portfolio" "Signal backup" "Sync"];
    };
    homepage = {
      enable = true;
      environmentFile = config.sops.secrets.homepage_env_file.path;
      domain = "home.${intraDomain}";
    };
    home-assistant = {
      enable = true;
      domain = "hass.${intraDomain}";
    };
  };
}
