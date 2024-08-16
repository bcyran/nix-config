rec {
  my = {
    programs = import ./programs;
    configurations = import ./configurations;
    presets = import ./presets;
    hardware = import ./hardware.nix;
  };

  default = my;
}
