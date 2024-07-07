{
  programs.direnv = {
    enable = true;
    config = {
      hide_env_diff = true;
    };
    nix-direnv.enable = true;
  };
}
