{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.configurations.ddcci;

  ddcutilBin = "${pkgs.ddcutil}/bin/ddcutil";
  sleepBin = "${pkgs.coreutils}/bin/sleep";

  kernel = config.boot.kernelPackages.kernel;
  kernelBuildDir = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";

  # FIXME: nixpkgs' kernel-modules aggregator now requires every external module to
  # carry a `.ko.cer` certificate next to it (see nixpkgs PR #571181).
  # ddcci-driver's upstream Makefile installed modules by hand (`install -m
  # 644 ddcci.ko ...`), which never produced that certificate and broke
  # `system.modulesTree` with e.g. `cat: extra/ddcci.ko.cer: No such file or
  # directory`. This nixpkgs pin predates the upstream fix
  # (https://github.com/NixOS/nixpkgs/pull/577222), so replicate it here:
  # build/install through the kernel's own make rules (`modules`/
  # `modules_install`) instead of the vendored Makefiles' custom targets.
  ddcciDriver = config.boot.kernelPackages.ddcci-driver.overrideAttrs (_: {
    __structuredAttrs = true;
    strictDeps = true;
    enableParallelBuilding = true;

    prePatch = "";

    makeFlags =
      config.boot.kernelPackages.kernelModuleMakeFlags
      ++ [
        "KERNELRELEASE=${kernel.modDirVersion}"
      ];

    installFlags = [
      "INSTALL_MOD_PATH=${placeholder "out"}"
    ];

    buildPhase = ''
      runHook preBuild
      make modules -C ${kernelBuildDir} M=$(pwd)/ddcci "''${makeFlags[@]}"
      make modules -C ${kernelBuildDir} M=$(pwd)/ddcci-backlight "''${makeFlags[@]}"
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      make modules_install -C ${kernelBuildDir} M=$(pwd)/ddcci \
        "''${makeFlags[@]}" "''${installFlags[@]}"
      make modules_install -C ${kernelBuildDir} M=$(pwd)/ddcci-backlight \
        "''${makeFlags[@]}" "''${installFlags[@]}"
      runHook postInstall
    '';
  });
in {
  options.my.configurations.ddcci.enable = lib.mkEnableOption "ddcci";

  config = lib.mkIf cfg.enable {
    boot = {
      kernelModules = ["i2c-dev" "ddcci_backlight"];
      extraModulePackages = [ddcciDriver];
    };

    environment.systemPackages = [pkgs.ddcutil];

    hardware.i2c.enable = true;
    users.groups.i2c.members = [config.my.user.name];

    # Source: https://discourse.nixos.org/t/brightness-control-of-external-monitors-with-ddcci-backlight/8639/15
    services.udev.extraRules = ''
      SUBSYSTEM=="i2c-dev", ACTION=="add",\
        TAG+="ddcci",\
        TAG+="systemd",\
        ENV{SYSTEMD_WANTS}+="ddcci@$kernel.service"
    '';

    systemd.services."ddcci@" = {
      description = "Force DDC/CI device detection";
      scriptArgs = "%i";
      script = ''
        echo "Trying to force DDC/CI device detection for $1."
        id=$(echo "$1" | cut -d "-" -f 2)
        for i in {1..5}; do
          echo "Attempt $i..."
          if ${ddcutilBin} getvcp 10 -b "$id"; then
            echo 'ddcci 0x37' > "/sys/bus/i2c/devices/$1/new_device"
            echo 'Success!'
            break
          fi
          sleep 1
        done
      '';
      serviceConfig = {
        Type = "oneshot";
        ExecStartPre = "${sleepBin} 3";
      };
    };
  };
}
