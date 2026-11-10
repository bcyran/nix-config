{
  config,
  pkgs,
  ...
}: {
  # NVIDIA driver stack for the RTX 4090 (Ada Lovelace).
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # NVIDIA recommends the open kernel modules on Turing and newer.
    open = true;
    nvidiaPersistenced = true;
  };

  # Driver libraries in /run/opengl-driver, which CUDA packages rpath against.
  hardware.graphics.enable = true;

  environment.systemPackages = [
    config.hardware.nvidia.package.bin # nvidia-smi
    pkgs.nvtopPackages.nvidia
  ];
}
