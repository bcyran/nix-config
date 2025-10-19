# TODO: Switch to HM module and nixpkgs package once new version  (after 25.9.3) is released.
{
  my,
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.colorScheme) palette;
  cfg = config.my.programs.anyrun;

  styleSheet = builtins.readFile ./style.css;

  preprocessScript = pkgs.writeShellScriptBin "anyrun-app-preprocess-script" ''
    command_name="$1"
    term_mode="$2" # "term" or "no-term"
    command="$3"

    if [[ "$term_mode" == "term" ]]; then
      exec uwsm app -- kitty "$command"
    else
      exec uwsm app -- "$command"
    fi
  '';
in {
  options.my.programs.anyrun.enable = lib.mkEnableOption "anyrun";

  config = lib.mkIf cfg.enable {
    programs.anyrun = {
      enable = true;
      package = my.inputs.anyrun.packages.${pkgs.system}.default;
      config = {
        plugins = with my.inputs.anyrun.packages.${pkgs.system};
          [
            applications
            shell
            rink
            translate
            websearch
          ]
          ++ [my.inputs.anyrun-powermenu.packages.${pkgs.system}.default];
        x = {fraction = 0.5;};
        y = {fraction = 0.3;};
        width = {absolute = 700;};
        hideIcons = false;
        layer = "overlay";
        closeOnClick = true;
        hidePluginInfo = false;
        keybinds = [
          {
            key = "Return";
            action = "select";
          }
          {
            key = "Down";
            action = "down";
          }
          {
            key = "Up";
            action = "up";
          }
          {
            key = "Tab";
            action = "down";
          }
          {
            key = "Escape";
            action = "close";
          }
          {
            ctrl = true;
            key = "n";
            action = "down";
          }
          {
            ctrl = true;
            key = "p";
            action = "up";
          }
          {
            ctrl = true;
            key = "y";
            action = "select";
          }
        ];
      };
      extraConfigFiles = {
        "applications.ron".text = ''
          Config(
            desktop_actions: false,
            max_entries: 5,
            preprocess_exec_script: Some("${preprocessScript}"),
            terminal: Some(Terminal(
              command: "kitty",
            )),
          )
        '';
        "shell.ron".text = ''
          Config(
            prefix: ">",
            shell: Some("fish"),
          )
        '';
        "translate.ron".text = ''
          Config(
            prefix: ":",
            language_delimiter: ">",
            max_entries: 3,
          )
        '';
        "websearch.ron".text = ''
          Config(
            prefix: "?",
            engines: [
              Custom(
                name: "Kagi",
                url: "kagi.com/search?q={}",
              ),
            ],
          )
        '';
        "powermenu.ron".text = ''
          Config(
            logout: (
              command: "hyprctl dispatch exit",
              confirm: true,
            ),
          )
        '';
      };
      extraCss = ''
        @define-color base00 #${palette.base00};
        @define-color base01 #${palette.base01};
        @define-color base02 #${palette.base02};
        @define-color base03 #${palette.base03};
        @define-color base04 #${palette.base04};
        @define-color base05 #${palette.base05};
        @define-color base06 #${palette.base06};
        @define-color base07 #${palette.base07};
        @define-color base08 #${palette.base08};
        @define-color base09 #${palette.base09};
        @define-color base0A #${palette.base0A};
        @define-color base0B #${palette.base0B};
        @define-color base0C #${palette.base0C};
        @define-color base0D #${palette.base0D};
        @define-color base0E #${palette.base0E};
        @define-color base0F #${palette.base0F};
        @define-color base10 #${palette.base10};
        @define-color base11 #${palette.base11};
        @define-color base12 #${palette.base12};
        @define-color base13 #${palette.base13};
        @define-color base14 #${palette.base14};
        @define-color base15 #${palette.base15};
        @define-color base16 #${palette.base16};
        @define-color base17 #${palette.base17};

        @define-color accent_primary #${palette.accentPrimary};
        @define-color accent_secondary #${palette.accentSecondary};
        @define-color warning #${palette.warning};
        @define-color error #${palette.error};

        * {
          font-family: "${builtins.elemAt config.fonts.fontconfig.defaultFonts.sansSerif 0}";
        }

        ${styleSheet}
      '';
    };
  };
}
