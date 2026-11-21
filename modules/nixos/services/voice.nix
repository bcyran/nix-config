{
  config,
  my,
  lib,
  ...
}: let
  cfg = config.my.services.voice;
in {
  options.my.services.voice = let
    serviceName = "Local voice services";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    sttPort = my.lib.options.mkPortOption serviceName 10300;
    ttsPort = my.lib.options.mkPortOption serviceName 10200;
    sttModel = lib.mkOption {
      type = lib.types.str;
      default = "medium-int8";
      example = "turbo";
      description = "Multilingual faster-whisper model used for speech-to-text.";
    };
    sttDevice = lib.mkOption {
      type = lib.types.enum ["cpu" "cuda" "auto"];
      default = "cpu";
      description = "Device used for speech-to-text inference.";
    };
    defaultLanguage = lib.mkOption {
      type = lib.types.str;
      default = "en";
      example = "pl";
      description = "Language used for speech-to-text when a client does not request one.";
    };
    defaultVoice = lib.mkOption {
      type = lib.types.str;
      default = "en_US-ryan-medium";
      example = "pl_PL-gosia-medium";
      description = ''
        Piper voice used when a client does not request one. It is downloaded
        at server startup; other voices are downloaded on first use.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.wyoming = {
      faster-whisper.servers.voice = {
        enable = true;
        model = cfg.sttModel;
        language = cfg.defaultLanguage;
        device = cfg.sttDevice;
        uri = "tcp://${cfg.address}:${toString cfg.sttPort}";
      };
      piper.servers.voice = {
        enable = true;
        voice = cfg.defaultVoice;
        uri = "tcp://${cfg.address}:${toString cfg.ttsPort}";
      };
    };
  };
}
