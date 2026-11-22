# AGENTS.md

Personal NixOS + Home Manager flake. User `bazyli`; hosts `slimbook` (laptop/desktop), `atlas` (home server, Nvidia, most services), `vps` (remote server). Arch: `x86_64-linux`. Nixpkgs follows `nixos-unstable`.

## Hard rules

1. **NEVER switch configurations.** Forbidden: `just switch|rollback|push`, `nh os|home switch`, `nixos-rebuild switch|boot|test`, `home-manager switch`, `switch-to-configuration`. Building is fine; activating is the user's job.
2. **Verify every option and package exists BEFORE writing it.** Never use names from memory. Use the `nixos` MCP `nix` tool:
   - `{action:"search", type:"options", query:"services.foo"}` (NixOS option)
   - `{action:"info", query:"pkgname"}` (package)
   - `{action:"search", source:"home-manager", query:"programs.foo"}` (HM option)
   - Check the option's type and default too. For options from flake inputs (disko, sops-nix, ...), read the input's source in `/nix/store`. Without MCP: `nix eval .#nixosConfigurations.<host>.options.<path>.type` or `nix search nixpkgs <pkg>`.
   - If you cannot verify a name, stop and say so (or ask); do not guess.
3. **After ANY edit, run in order:** `git add` new files → `just build <host>` (no argument = current host; `just build all` for shared code in `modules/`, `lib/`, `overlays/`, `pkgs/`) → `just check` (runs `alejandra --check`, `statix`, `nix flake check`; fix formatting with `alejandra .`). Fix errors and rerun until both pass. Do not call a task done without both passing; if you could not run them, say so.
4. **Never read, decrypt, or print `secrets/*.yaml`**, and never put secrets in Nix code (the store is world-readable). Use sops: `config.sops.secrets.<name>.path`.

## Practical notes

- `git add` new files before building (flakes ignore untracked files). Do not commit unless asked.
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
| New NixOS service | skill `new-nixos-service` |
| New HM program | new `modules/home-manager/programs/<name>.nix`; enable in a preset or `hosts/<host>/home-manager/bazyli.nix` |
| Host-specific NixOS setting | `hosts/<host>/nixos/configuration.nix` or sibling file |
| Host-specific HM setting | `hosts/<host>/home-manager/bazyli.nix` |
| Custom package | skill `new-package` |
| Nixpkgs override/patch | skill `overlay-patch` |
| New host | `hosts/<host>/{common,nixos,home-manager}/` + `mkSystem` and `mkHome` entries in `flake.nix` |
| New secret | declare in host `sops.secrets`; ask the user to add the value |
| Neovim / Hyprland config | Lua under `modules/home-manager/programs/{neovim,hyprland}/files/` |
| Preset (group of enabled modules) | `modules/{nixos,home-manager}/presets/<name>.nix`, using `lib.mkDefault` |

## Skills

Repo-local skills in `.agents/skills/`:

- `new-nixos-service`: use when adding a service that has an upstream NixOS module
- `new-package`: use when software is not in nixpkgs (`pkgs/` workflow)
- `oci-container-service`: use when only a container image exists (rootless Podman)
- `overlay-patch`: use when a nixpkgs package is broken or needs a patch (`overlays/`)
