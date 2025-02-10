{config, ...}: let
  caddyCfg = config.services.caddy;
in {
  sops.secrets = {
    caddy_env_file = {
      owner = caddyCfg.user;
      reloadUnits = ["caddy.service"];
    };
    deploy_cyran_dev_ssh_key_file = {
      owner = caddyCfg.user;
      reloadUnits = ["caddy.service"];
    };
  };

  my = {
    services = {
      caddy = {
        enable = true;
        address = "0.0.0.0";
        openFirewall = true;
        environmentFile = config.sops.secrets.caddy_env_file.path;
        # This pulls the repo, runs `nix build` and serves the result.
        # Webhook to the /_update endpoint triggers the update.
        staticGitHosts = {
          "cyran.dev" = {
            repoUrl = "git@github.com:bcyran/bazyli-cyran.git";
            sshKeyFile = config.sops.secrets.deploy_cyran_dev_ssh_key_file.path;
            updateWebhookConfig = "Github X-Hub-Signature-256 {$GITHUB_CYRAN_DEV_WEBHOOK_SECRET}";
          };
        };
      };
    };
    # This module from my `nix-private` flake enables more websites in the same way as
    # `staticGitHosts` above.
    private.websites.enable = true;
  };
}
