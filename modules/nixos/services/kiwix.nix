{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.kiwix;

  kiwixServeBin = "${pkgs.kiwix-tools}/bin/kiwix-serve";
  kiwixServeArgs = [
    "--address=${cfg.address}"
    "--port=${toString cfg.port}"
    "--library"
    "--monitorLibrary"
    "${cfg.libraryPath}/${cfg.libraryFileName}"
  ];
  kiwixServeArgsStr = lib.concatStringsSep " " kiwixServeArgs;
in {
  options.my.services.kiwix = let
    serviceName = "kiwix";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8090;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;

    libraryPath = lib.mkOption {
      type = lib.types.path;
      example = "/var/lib/kiwix/library";
      description = "Path to the Kiwix library directory.";
    };
    libraryFileName = lib.mkOption {
      type = lib.types.str;
      default = "library.xml";
      description = "Name of the Kiwix library file.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.kiwix = {
      description = "Kiwix server";
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        ExecStart = "${kiwixServeBin} ${kiwixServeArgsStr}";
      };
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
