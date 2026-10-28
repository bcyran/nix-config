{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.podman;

  rootlessStorageDir = "/var/lib/containers/rootless";
in {
  options.my.programs.podman = {
    enable = lib.mkEnableOption "podman";
  };

  config = lib.mkIf cfg.enable {
    virtualisation = {
      containers = {
        enable = true;
        storage.settings.storage.rootless_storage_path = "${rootlessStorageDir}/$UID";
      };

      oci-containers.backend = "podman";

      podman = {
        enable = true;
        dockerCompat = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
        # Prevent aardvark-dns from starting on port 53 and conflicting with blocky.
        # The changedetection-io nixpkgs module unconditionally sets dns_enabled = true,
        # but container-to-container DNS is not needed in this setup.
        defaultNetwork.settings.dns_enabled = lib.mkForce false;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${rootlessStorageDir} 1777 root root - -"
    ];
  };
}
