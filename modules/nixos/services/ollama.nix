{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.ollama;
in {
  options.my.services.ollama = {
    enable = lib.mkEnableOption "ollama";

    port = lib.mkOption {
      type = lib.types.int;
      default = 11434;
      description = "The port on which the Ollama is accessible.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      example = "ollama.home.my.tld";
      description = "The domain on which the Ollama is accessible.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      host = "0.0.0.0";
      inherit (cfg) port;
      openFirewall = true;
      acceleration = false;
    };
  };
}
