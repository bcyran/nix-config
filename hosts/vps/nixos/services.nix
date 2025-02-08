{
  config,
  lib,
  pkgs,
  ...
}: let
  caddyCfg = config.services.caddy;

  nixBin = lib.getExe pkgs.nix;
  wwwDir = "/srv/www";
in {
  sops.secrets = {
    caddy_env_file = {
      owner = caddyCfg.user;
      reloadUnits = ["caddy.service"];
    };
    deploy_bazyli_cyran_ssh_key_file = {
      owner = caddyCfg.user;
      reloadUnits = ["caddy.service"];
    };
  };

  my.services = {
    caddy = {
      enable = true;
      address = "0.0.0.0";
      openFirewall = true;
      environmentFile = config.sops.secrets.caddy_env_file.path;
    };
  };

  systemd.tmpfiles.rules = [
    "d '${wwwDir}' 0750 ${caddyCfg.user} ${caddyCfg.group} - -"
  ];

  services.caddy = {
    globalConfig = ''
      git {
        repo cyran.dev {
          base_dir ${wwwDir}
          url git@github.com:bcyran/bazyli-cyran.git
          auth key ${config.sops.secrets.deploy_bazyli_cyran_ssh_key_file.path} no_strict_host_key_check
          branch production
          webhook Github X-Hub-Signature-256 {$GITHUB_CYRAN_DEV_WEBHOOK_SECRET}

          post pull exec {
            name Build
            command ${nixBin}
            args build ${wwwDir}/cyran.dev -o ${wwwDir}/cyran.dev/result
          }
        }
      }
    '';
    extraConfig = ''
      cyran.dev {
        route /_update {
          git update repo cyran.dev
        }

        route {
          file_server {
            root ${wwwDir}/cyran.dev/result
          }
        }

        log {
          output file /var/log/caddy/access-cyran.dev.log {
            roll_size 100MiB
            roll_keep 5
            roll_keep_for 2160h
            mode 644
          }
        }
      }
    '';
  };
}
