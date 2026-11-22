---
name: new-nixos-service
description: Add a new opt-in NixOS service module under modules/nixos/services and enable it on a host (atlas, vps). Use when asked to add/set up a service that has an upstream NixOS module.
---

# New NixOS service

Rule most often skipped: `git add` the new file before any `nix` command (flakes ignore untracked files).

1. Verify the upstream module (AGENTS.md rule 2): search `services.<name>`; note option types and defaults.
   - No NixOS module but a package is needed: skill `new-package`, then a custom systemd unit.
   - Only a container image exists: skill `oci-container-service`.
2. Copy a similar native module from `modules/nixos/services/` (e.g. `audiobookshelf.nix`, `bazarr.nix`, `calibre-web.nix`). No import edit needed.
3. Write `modules/nixos/services/<name>.nix`. Skeleton:

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
    serviceName = "Foo";
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
      # map cfg.address / cfg.port to the REAL upstream option names (verified in step 1)
    };
    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
```

## Helpers (`my.lib`, see `lib/options.nix`)
- `options.mkAddressOption`, `mkPortOption name default`, `mkOpenFirewallOption`, `mkReverseProxyOptions`, `mkUserOption`, `mkGroupOption`, `mkEnvironmentFileOption(s)` (all take the service name).
- `caddy.mkReverseProxy cfg` -> value for `my.services.caddy.reverseProxyHosts`.

## Rules
- Default bind `127.0.0.1`; expose via Caddy; open firewall only via `openFirewall`.
- Secrets: declare `sops.secrets.<name>` in the host; use `config.sops.secrets.<name>.path` or `mkEnvironmentFileOption`; ask the user to add the value.
- Unused port: `grep -rhn mkPortOption modules/nixos/services` and pick a default not listed.

## Enable and verify
1. Enable in `hosts/<host>/nixos/services.nix` (`my.services.<name>.enable = true;` + `reverseProxy.domain`), copying a neighbouring entry.
2. `git add` the file.
3. `nix eval .#nixosConfigurations.<host>.config.my.services.<name>.enable` (expect `true`).
4. `just build <host>`, then `just check` (AGENTS.md rules 3-4).
