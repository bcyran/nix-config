{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.wyoming-openai-gateway;
  voiceCfg = config.my.services.voice;
in {
  options.my.services.wyoming-openai-gateway = let
    serviceName = "Wyoming OpenAI gateway";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8555;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    upstream = {
      address = lib.mkOption {
        type = lib.types.str;
        default = voiceCfg.address;
        description = "Address of the Wyoming speech servers proxied by the gateway.";
      };
      sttPort = lib.mkOption {
        type = lib.types.int;
        default = voiceCfg.sttPort;
        description = "Port of the Wyoming speech-to-text server.";
      };
      ttsPort = lib.mkOption {
        type = lib.types.int;
        default = voiceCfg.ttsPort;
        description = "Port of the Wyoming text-to-speech server.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = voiceCfg.enable;
        message = "my.services.wyoming-openai-gateway requires my.services.voice to be enabled.";
      }
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    systemd.services.wyoming-openai-gateway = {
      description = "OpenAI-compatible API gateway for Wyoming speech services";
      after = [
        "network.target"
        "wyoming-faster-whisper-voice.service"
        "wyoming-piper-voice.service"
      ];
      wantedBy = ["multi-user.target"];

      environment = {
        HOST = cfg.address;
        PORT = toString cfg.port;
        STT_HOST = cfg.upstream.address;
        STT_PORT = toString cfg.upstream.sttPort;
        TTS_HOST = cfg.upstream.address;
        TTS_PORT = toString cfg.upstream.ttsPort;
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe my.pkgs.wyoming-openai-gateway;
        Restart = "on-failure";

        DynamicUser = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = ["AF_INET" "AF_INET6"];
      };
    };
  };
}
