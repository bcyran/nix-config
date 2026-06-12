{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.podman;
in {
  options.my.programs.podman = {
    enable = lib.mkEnableOption "podman";
  };

  config = lib.mkIf cfg.enable {
    virtualisation = {
      containers.enable = true;

      oci-containers.backend = "podman";

      podman = {
        enable = true;
        dockerCompat = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
        # Used for exposing host's localhost to the container:
        # --network=slirp4netns:allow_host_loopback=true.
        extraPackages = [pkgs.slirp4netns];
        # Prevent aardvark-dns from starting on port 53 and conflicting with blocky.
        # The changedetection-io nixpkgs module unconditionally sets dns_enabled = true,
        # but container-to-container DNS is not needed in this setup.
        defaultNetwork.settings.dns_enabled = lib.mkForce false;
      };
    };
  };
}
