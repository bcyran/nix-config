{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.configurations.printing;
in {
  options.my.configurations.printing.enable = lib.mkEnableOption "printing";

  config = lib.mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = with pkgs; [gutenprint cups-brother-hl1210w];
      browsing = true;
      browsedConf = ''
        BrowseDNSSDSubTypes _cups,_print
        BrowseLocalProtocols all
        BrowseRemoteProtocols all
        CreateIPPPrinterQueues All

        BrowseProtocols all
      '';
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
