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
        # Used for exposing host's localhost to the container:
        # --network=slirp4netns:allow_host_loopback=true.
        extraPackages = [pkgs.slirp4netns];
      };
    };
  };
}
