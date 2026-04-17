hosts := `ls -d hosts/*/ | xargs -n1 basename`
current_host := `hostname`
current_user := `whoami`
target := "ssh://atlas"

# Update flake inputs (or a specific input).
update *input:
    nix flake update {{ input }}

# Build NixOS and home-manager configs for a host (or "all").
build host=current_host user=current_user:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{ host }}" = "all" ]; then
        hosts="{{ hosts }}"
    else
        hosts="{{ host }}"
    fi
    for h in $hosts; do
        echo "Building NixOS config for $h..."
        nix build ".#nixosConfigurations.$h.config.system.build.toplevel"
        echo "Building home-manager config for {{ user }}@$h..."
        nix build ".#homeConfigurations.{{ user }}@$h.activationPackage"
    done

# Copy NixOS and home-manager configs for a host (or "all") to the target store.
push host=current_host user=current_user:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{ host }}" = "all" ]; then
        hosts="{{ hosts }}"
    else
        hosts="{{ host }}"
    fi
    for h in $hosts; do
        echo "Pushing NixOS config for $h..."
        nix copy --to "{{ target }}" ".#nixosConfigurations.$h.config.system.build.toplevel"
        echo "Pushing home-manager config for {{ user }}@$h..."
        nix copy --to "{{ target }}" ".#homeConfigurations.{{ user }}@$h.activationPackage"
    done

# Switch NixOS and home-manager configs using nh.
switch host=current_host user=current_user:
    nh os switch . --hostname {{ host }}
    nh home switch . --configuration {{ user }}@{{ host }}

# Rollback to a previous NixOS and/or home-manager generation.
rollback target="both" generations="1":
    #!/usr/bin/env bash
    set -euo pipefail
    n="{{ generations }}"
    if [ "{{ target }}" = "both" ] || [ "{{ target }}" = "system" ]; then
        profile="/nix/var/nix/profiles/system"
        gen=$(sudo nix-env --list-generations -p "$profile" | tail -n $((n + 1)) | head -n 1 | awk '{print $1}')
        sudo nix-env -p "$profile" --switch-generation "$gen"
        sudo "$profile/bin/switch-to-configuration" switch
    fi
    if [ "{{ target }}" = "both" ] || [ "{{ target }}" = "home" ]; then
        activation=$(home-manager generations | sed -n "$((n + 1))p" | sed 's/.*-> //')
        "$activation/activate"
    fi
