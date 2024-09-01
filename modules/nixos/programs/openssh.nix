{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.openssh;
in {
  options.my.programs.openssh.enable = lib.mkEnableOption "openssh";

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        StreamLocalBindUnlink = "yes";
      };
    };
  };
}
