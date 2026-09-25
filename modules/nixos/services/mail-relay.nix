{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.mail-relay;
in {
  options.my.services.mail-relay = {
    enable = lib.mkEnableOption "outgoing mail relay";

    relayHost = lib.mkOption {
      type = lib.types.str;
      description = "The SMTP relay host (with brackets and port).";
    };

    saslPasswordFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file with the SMTP sasl_passwd entry, one line: \"[relay]:port user:password\". The username here is the address the relay authenticates as and sends from (it must be an address with an SMTP token in Proton).";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "${config.networking.hostName}.${my.lib.const.domains.intra}";
      description = "The mail hostname used by Postfix.";
    };

    senderAddress = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Address all outbound mail is sent from: envelope sender and From header are rewritten to it. Must be an address owned by the Proton mailbox that owns the SMTP token (the username in saslPasswordFile).";
    };

    rootAliasAddress = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = config.my.user.email;
      description = "Address to which mail addressed to root/postmaster on this host is forwarded.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.postfix = {
      enable = true;
      setSendmail = true;
      rootAlias = cfg.rootAliasAddress;

      settings.main = {
        myhostname = cfg.hostname;
        relayhost = [cfg.relayHost];
        inet_interfaces = "loopback-only";
        mynetworks = ["127.0.0.0/8" "[::1]/128"];
        smtp_tls_security_level = "encrypt";
        smtp_sasl_auth_enable = "yes";
        smtp_sasl_security_options = "noanonymous";
        smtp_sasl_password_maps = "texthash:${cfg.saslPasswordFile}";
        sender_canonical_maps = "static:${cfg.senderAddress}";
      };
    };
  };
}
