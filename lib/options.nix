# Helpers used in ../modules/nixos/services.
{lib}: {
  mkAddressOption = serviceName:
    lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "The IP address to which the ${serviceName} will bind.";
    };

  mkPortOption = serviceName: default:
    lib.mkOption {
      type = lib.types.int;
      description = "The port to which the ${serviceName} will bind.";
      inherit default;
    };

  mkDomainOption = serviceName:
    lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "service.home.my.tld";
      description = "The domain on which the ${serviceName} is accessible.";
    };

  mkOpenFirewallOption = serviceName:
    lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the firewall for the ${serviceName}.";
    };

  mkEnvironmentFileOption = serviceName:
    lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/path/to/env/file";
      description = "The path to the environment file.";
    };

  mkEnvironmentFilesOption = serviceName:
    lib.mkOption {
      type = with lib.types; listOf path;
      default = [];
      example = ["/path/to/env/file"];
      description = "The paths to the environment files.";
    };
}
