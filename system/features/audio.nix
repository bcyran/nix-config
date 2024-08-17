{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.configurations.audio;
in {
  options.my.configurations.audio.enable = mkEnableOption "audio";

  config = mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    environment.systemPackages = with pkgs; [
      wireplumber
      pavucontrol
    ];
  };
}
