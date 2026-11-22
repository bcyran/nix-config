---
name: overlay-patch
description: Override or patch a nixpkgs package in overlays/default.nix (build fixes, backported PRs, patch files, disabled tests). Use when a nixpkgs package is broken or needs a change.
---

# Overlay patch

Rule most often skipped: every entry needs a `# FIXME:` comment with cause, link, and removal condition.

File: `overlays/default.nix`. Put fixes in the `fixes` overlay (`final: prev: {...}`), following existing entries. `pkgs.stable.<name>` pins a package to `nixpkgs-stable`.

## Steps
1. Reproduce: `nix build nixpkgs#<pkg>` or `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`; read `nix log <drv>`.
2. Check whether nixpkgs already fixed it (issues/PRs, MCP `info`). If so, tell the user instead of patching.
3. Pick the least invasive form (use `prev`):
   - Inputs/hooks: `prev.foo.overrideAttrs (old: {buildInputs = (old.buildInputs or []) ++ [prev.bar];})`
   - Feature args: `prev.foo.override {withX = false;}` (verify the arg exists)
   - Patch file: `patches = (old.patches or []) ++ [./foo-fix.patch];`, file next to `overlays/default.nix` (example: `mini-graph-card-gradient.patch`)
   - Upstream PR: `prev.fetchpatch2 {url = "..."; hash = lib.fakeHash;}` then fix the hash
   - Flaky tests: `disabledTests`, `disabledTestPaths`, then `doCheck = false` (narrowest first)
   - Newer version: override `version` + `src`, or add a `pkgs/` package if it diverges a lot.
4. Comment, e.g. (real entry, `git-chain`):
   ```nix
   # FIXME: <cause, one or two lines>. Remove when nixpkgs <fix condition>.
   git-chain = prev.git-chain.overrideAttrs (old: {
     preBuild = (old.preBuild or "") + "\nexport LIBGIT2_NO_VENDOR=0\n";
   });
   ```
5. `git add` any new patch file.
6. `nix build` the package, then `just build all` (overlays are shared), then `just check`.
