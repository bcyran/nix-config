{
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
      };
    };
  };
}
