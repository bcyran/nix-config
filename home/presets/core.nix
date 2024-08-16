{
  pkgs,
  outputs,
  nix-colors,
  ...
}: {
  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      # outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
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

  imports =
    [
      nix-colors.homeManagerModules.default
    ]
    ++ (builtins.attrValues outputs.homeManagerModules);

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
