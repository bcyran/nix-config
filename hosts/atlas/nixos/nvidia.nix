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

  nixpkgs.config.cudaSupport = true;

  nix.settings = {
    substituters = [
      "https://cache.nixos-cuda.org"
    ];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  # Jellyfin's OpenCL tone mapping derives a VAAPI device from render node 0.
  # That is the NVIDIA GPU, whose VA-API driver cannot encode. Show the AMD
  # iGPU (renderD129) under that name inside the Jellyfin service.
  systemd.services.jellyfin.serviceConfig.BindPaths = ["/dev/dri/renderD129:/dev/dri/renderD128"];
}
