{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.configurations.printing;
in {
  options.my.configurations.printing.enable = mkEnableOption "printing";

  config = mkIf cfg.enable {
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
