{lib, ...}: {
  services = {
    sanoid = {
      enable = true;
      datasets = {
        "zroot/root" = {
          use_template = ["atlas"];
          recursive = false;
        };
        "zfast_store/fast_store/var_lib" = {
          use_template = ["atlas"];
          recursive = true;
        };
      };
      templates = {
        atlas = {
          hourly = 24;
          daily = 14;
          monthly = 0;
          yearly = 0;
          autosnap = true;
          autoprune = true;
        };
      };
    };
  };

  systemd.services = let
    notifyFailedServices = [
      "sanoid"
    ];
    mkOnFailure = serviceName: {
      onFailure = ["ntfy-failed@${serviceName}.service"];
    };
  in
    lib.genAttrs notifyFailedServices mkOnFailure;
}
