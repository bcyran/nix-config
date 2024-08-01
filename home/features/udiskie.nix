{pkgs, ...}: {
  services.udiskie = {
    enable = true;
    automount = true;
    tray = "never";
    settings = {
      program_options = {
        file_manager = "thunar";
        terminal = "alacritty --working-directory";
      };
      device_config = [
        {
          id_uuid = "e028f76b-e2a1-4a92-89a5-2fc5aeac615b";
          keyfile = "/home/bazyli/.backup_key";
          automount = true;
          ignore = false;
        }
      ];
    };
  };
  home.packages = [pkgs.udiskie];
}
