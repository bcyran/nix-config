{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.configurations.audio;
in {
  options.my.configurations.audio.enable = lib.mkEnableOption "audio";

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    environment.systemPackages = with pkgs; [
      pavucontrol
    ];
  };
}
