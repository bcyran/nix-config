{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.immich;

  mlModelName = "nllb-clip-base-siglip__mrl";
in {
  options.my.services.immich = let
    serviceName = "Immich";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 2283;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      host = cfg.address;
      inherit (cfg) port openFirewall;
      settings = {
        newVersionCheck.enabled = false;
        machineLearning.clip = {
          enabled = true;
          modelName = mlModelName;
        };
        ffmpeg = {
          transcode = "required";
          targetResolution = "1080";
          preset = "slow";
          crf = 20;
          accel = "vaapi";
          accelDecode = true;
        };
      };
    };

    hardware.graphics.enable = true;
    systemd.services.immich-server.serviceConfig = {
      PrivateDevices = lib.mkForce false;
      DeviceAllow = ["char-drm rw"];
      SupplementaryGroups = ["video" "render"];
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
