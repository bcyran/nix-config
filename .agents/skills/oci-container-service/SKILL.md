---
name: oci-container-service
description: Add a NixOS service that runs a rootless Podman container via virtualisation.oci-containers. Use when no NixOS module/package exists but a container image does.
---

# OCI container service

Rule most often skipped: pin an explicit image version tag, never `latest`.

Same flow as skill `new-nixos-service` (Caddy, firewall, enable, verify). Reference module: `modules/nixos/services/apprise.nix`; copy it. Helpers: `lib/oci-containers.nix`.

## Checklist (differences from a native service)
- Options: add `user`, `group` (`mkUserOption`, `mkGroupOption`) and `allowedLoopbackPorts` (`mkAllowedLoopbackPortsOption`).
- `let` block:
  ```nix
  # renovate: datasource=docker packageName=docker.io/org/image
  imageVersion = "1.2.3";
  dataDir = "/var/lib/<name>";
  uid = 2010; # next free: grep -rhn "uid = " modules/nixos/services
  ```
  Existing uids are sequential from 2002. `netalertx` (20211) is an image-mandated exception. `mkRootlessPodmanUser` also sets `gid = uid`.
- Config: `lib.mkIf cfg.enable (lib.mkMerge [ {...} (my.lib.ociContainers.mkRootlessPodmanUser {inherit (cfg) user group; home = dataDir; inherit uid;}) ])`.
- Container block (from apprise):
  ```nix
  virtualisation.oci-containers.containers.<name> = {
    image = "docker.io/org/image:${imageVersion}";
    autoStart = true;
    ports = ["${cfg.address}:${toString cfg.port}:<containerPort>"];
    volumes = ["${dataDir}/config:/config"];
    environment = {
      PUID = toString config.users.users.${cfg.user}.uid;
      PGID = toString config.users.groups.${cfg.group}.gid;
    };
    extraOptions =
      my.lib.ociContainers.mkLoopbackNetworkOptions cfg.allowedLoopbackPorts
      ++ ["--userns=keep-id" "--cap-drop=ALL" "--security-opt=no-new-privileges"];
    podman.user = cfg.user;
  };
  ```
- Host dirs: `systemd.tmpfiles.rules = ["d '${dataDir}/config' 0750 ${cfg.user} ${cfg.group} - -"];`
- Secrets: `environmentFiles` via `mkEnvironmentFileOption`; never inline.
- Keep `--cap-drop=ALL` and `no-new-privileges`; add caps only if the image fails without them. From the image docs, confirm the container listen port, data paths, and non-root support (`--userns=keep-id`, PUID/PGID, or `--user`).
- Needs a host service on loopback (e.g. a DB)? Use `allowedLoopbackPorts`, not host networking.

## Verify
`git add` the file; `nix eval .#nixosConfigurations.<host>.config.virtualisation.oci-containers.containers.<name>.image`; `just build <host>`; `just check`.
