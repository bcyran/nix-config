{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.cameractrls;
in {
  options.my.programs.cameractrls.enable = lib.mkEnableOption "cameractrls";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.cameractrls-gtk4
    ];

    xdg.configFile."hu.irl.cameractrls/usb-Anker_PowerConf_C200_Anker_PowerConf_C200_ACNV9P1E21573226-video-index0.ini".text = ''
      [preset_1]
      brightness = 50
      contrast = 50
      saturation = 50
      hue = 0
      white_balance_automatic = 1
      gamma = 400
      power_line_frequency = disabled
      sharpness = 50
      pan_absolute = 36000
      tilt_absolute = 7200
      focus_automatic_continuous = 1
      zoom_absolute = 200
      pixelformat = YUYV
      resolution = 640x480
      fps = 30
    '';

    # NOTE: In theory running the cameractrlsd daemon should automatically restore the settings
    #       to the preset above. However, it doesn't seem to work for my Anker PowerConf C200.
    #       See: https://github.com/soyersoyer/cameractrls/issues/61.
  };
}
