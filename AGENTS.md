# AGENTS.md

Personal NixOS + Home Manager flake. User `bazyli`; hosts `slimbook` (laptop/desktop), `atlas` (home server, Nvidia, most services), `vps` (remote server). Arch: `x86_64-linux`. Nixpkgs follows `nixos-unstable`.

## Hard rules

1. **NEVER switch configurations.** Forbidden: `just switch|rollback|push`, `nh os|home switch`, `nixos-rebuild switch|boot|test`, `home-manager switch`, `switch-to-configuration`. Building is fine; activating is the user's job.
2. **Verify every option and package exists BEFORE writing it.** Never use names from memory. Use the `nixos` MCP server via `execute`:
   - `tools.nixos.nix({action:"search", type:"options", query:"services.foo"})` (NixOS option)
   - `tools.nixos.nix({action:"info", query:"pkgname"})` (package)
   - `tools.nixos.nix({action:"search", source:"home-manager", query:"programs.foo"})` (HM option)
   - Check the option's type and default too. For options from flake inputs (disko, sops-nix, ...), read the input's source in `/nix/store`. If you cannot verify, say so; do not guess.
3. **ALWAYS verify the build AFTER writing code.** Run `just build <host>` (e.g. `just build atlas`; no argument = current host). Use `just build all` for changes to shared code (`modules/`, `lib/`, `overlays/`, `pkgs/`). Fix errors and rebuild until it passes. Do not call a task done without a passing build; if you could not run it, say so.
4. **Never read, decrypt, or print `secrets/*.yaml`**, and never put secrets in Nix code (the store is world-readable). Use sops: `config.sops.secrets.<name>.path`.

## Practical notes

- `git add` new files before building (flakes ignore untracked files). Do not commit unless asked.
- Before finishing also run `nix fmt` (alejandra) and `statix check`; CI enforces both.
- Do not hand-edit `flake.lock`, `hardware-configuration.nix`, `agent-skills/sources.lock.json`. Do not run `nix flake update` unless asked.
- Builds are slow. For a quick check use `nix eval .#nixosConfigurations.<host>.config.<option path>`.
- `just --list` shows all recipes. `nix build .#<name>` builds a custom package.

## Layout

```
flake.nix           inputs/outputs; hosts registered via mkSystem / mkHome
lib/                helpers, available as `my.lib`
modules/common/     shared NixOS+HM: my.user, my.colorscheme (tokyonight)
modules/nixos/{configurations,services,presets}/    `my.configurations.*`, `my.services.*`, `my.presets.*`
modules/home-manager/{configurations,programs,presets}/   `my.configurations.*`, `my.programs.*`, `my.presets.*`
hosts/<host>/nixos/configuration.nix        NixOS entry point (+ sibling files: services.nix, disks.nix, ...)
hosts/<host>/home-manager/bazyli.nix        Home Manager entry point
hosts/<host>/common/host.nix                my.user / colorscheme for the host
hosts/common/       files shared between hosts
pkgs/               custom packages (one dir each), registered in pkgs/default.nix
overlays/default.nix  nixpkgs overrides and patches
secrets/            sops-encrypted, do not touch
```

## Conventions

- **Everything is an opt-in `my.*` module**: defines `options.my.<area>.<name>.enable`, config under `lib.mkIf cfg.enable`. Hosts only enable/configure modules. Presets use `lib.mkDefault`.
- **Modules auto-import**: each `default.nix` uses `my.lib.listDirModules ./.`, so a new file in a module directory needs no import edit.
- Module args: `{my, config, lib, pkgs, ...}`. `my` is this flake: `my.lib`, `my.pkgs` (custom packages), `my.inputs`.
- Home Manager is **standalone** (`homeConfigurations."bazyli@<host>"`), separate module tree from NixOS.
- Colors: use `config.my.colorscheme.palette`, never hardcode.
- Services bind to `127.0.0.1`, are exposed via Caddy, and open the firewall only through an `openFirewall` option.
- Style: alejandra format, one function arg per line with trailing `...`, `let cfg = config.my...; in`. Sparse comments, only for non-obvious things. Reuse `my.lib` helpers. Make minimal changes; no unrelated refactors or unused options.
- Commits (only if asked): `feat(nixos/zigbee2mqtt): ...`, `fix(hosts/atlas): ...`.

## Where to edit

| Goal | Edit |
| --- | --- |
| New NixOS service | new `modules/nixos/services/<name>.nix`; enable in `hosts/<host>/nixos/services.nix` (atlas, vps) |
| New HM program | new `modules/home-manager/programs/<name>.nix`; enable in a preset or `hosts/<host>/home-manager/bazyli.nix` |
| Host-specific NixOS setting | `hosts/<host>/nixos/configuration.nix` or sibling file |
| Host-specific HM setting | `hosts/<host>/home-manager/bazyli.nix` |
| Custom package | `pkgs/<name>/default.nix` + entry in `pkgs/default.nix` |
| Nixpkgs override/patch | `overlays/default.nix` |
| New host | `hosts/<host>/{common,nixos,home-manager}/` + `mkSystem` and `mkHome` entries in `flake.nix` |
| New secret | declare in host `sops.secrets`; ask the user to add the value |
| Neovim / Hyprland config | Lua under `modules/home-manager/programs/{neovim,hyprland}/files/` |

## `my.lib` helpers for services

- `my.lib.options.mkAddressOption name`, `mkPortOption name default`, `mkOpenFirewallOption name`, `mkReverseProxyOptions name`, `mkEnvironmentFileOption(s) name`
- `my.lib.caddy.mkReverseProxy cfg` assigned to `my.services.caddy.reverseProxyHosts`
- `my.lib.ociContainers` (rootless Podman helpers), `my.lib.const` (domains, ports, wireguard), `my.lib.colors`

## Service module template

Copy this shape (real example: `modules/nixos/services/ntfy.nix`). HM program example: `modules/home-manager/programs/btop.nix`.

```nix
{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.foo;
in {
  options.my.services.foo = let
    serviceName = "foo";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8080;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];
    services.foo = {
      enable = true;
      settings = {
        listen = "${cfg.address}:${toString cfg.port}";
        base-url = "https://${cfg.reverseProxy.domain}";
      };
    };
    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
```
