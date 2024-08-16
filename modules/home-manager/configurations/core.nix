{
  pkgs,
  config,
  outputs,
  lib,
  ...
}:
with lib; let
  cfg = config.my.configurations.core;
in {
  options.my.configurations.core.enable = mkEnableOption "core";

  config = mkIf cfg.enable {
    nixpkgs = {
      overlays = [
        outputs.overlays.additions
        outputs.overlays.modifications
      ];

      config = {
        # Disable if you don't want unfree packages
        allowUnfree = true;
        # Workaround for https://github.com/nix-community/home-manager/issues/2942
        allowUnfreePredicate = _: true;
      };
    };

    nix = {
      package = pkgs.nix;
      settings = {
        experimental-features = "nix-command flakes";
        auto-optimise-store = true;
        warn-dirty = false;
      };
    };

    programs.home-manager.enable = true;
    services.ssh-agent.enable = true;
    systemd.user = {
      enable = true;
      # Nicely reload system units when changing configs
      startServices = "sd-switch";
      # This makes the tray.target stop when logging out and start again when logging in.
      # It's important because otherwise it's constantly active and thus services relying on it
      # don't start in proper sequence when logging out and logging in again.
      targets.tray.Unit.StopWhenUnneeded = true;
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home.stateVersion = "23.11";
  };
}
