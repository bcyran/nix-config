# Generic, abstract reverse proxy configuration options.
# Services use those options to avoid coupling them with configuration of the specific server.
{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.my.services.reverseProxy = {
    HTTPPort = mkOption {
      type = types.int;
      default = 80;
      description = "The port on which the reverse proxy listens for HTTP connections.";
    };

    HTTPSPort = mkOption {
      type = types.int;
      default = 443;
      description = "The port on which the reverse proxy listens for HTTPS connections.";
    };

    virtualHosts = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            backendAddress = mkOption {
              type = types.str;
              description = "The address of the backend server.";
              example = "127.0.0.1";
            };
            backendPort = mkOption {
              type = types.int;
              description = "The port of the backend server.";
              example = 2137;
            };
          };
        }
      );
      default = {};
      description = "List of virtual hosts to configure reverse proxy for.";
    };
  };
}
