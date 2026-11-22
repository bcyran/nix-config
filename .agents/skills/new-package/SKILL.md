---
name: new-package
description: Add a custom package under pkgs/ (fetch source, hashes, register, build, inspect result). Use when something is not in nixpkgs or needs a custom derivation.
---

# New custom package

Rule most often skipped: `git add pkgs/<name>` before every build (untracked files are invisible to flakes).

1. Check nixpkgs first (MCP `info`). If present, use it, or patch it via skill `overlay-patch`.
2. Copy a package of the same builder type from `pkgs/` (e.g. `pkgs/koinsight` = `buildNpmPackage` + `fetchFromGitHub`). Verify builder args exist; never guess.
3. Create `pkgs/<name>/default.nix`: args `{lib, <deps>, ...}:`, `pname`, `version`, `src`, `meta` (description, license, mainProgram). Pin `rev = "v${version}"`.
4. Set every hash (`hash`, `npmDepsHash`, `cargoHash`, `vendorHash`, ...) to `lib.fakeHash`. Build, copy the `got:` hash from the error, repeat per hash.
5. Register in `pkgs/default.nix`: `<name> = pkgs.callPackage ./<name> {};`. Extra deps from other sets: `{ inherit (python314Packages) foo; }` as done there.
6. `git add pkgs/<name>`.
7. `nix build .#<name> -L`; fix errors until it succeeds.
8. `ls result/bin && result/bin/<name> --version` (or `--help`). Then `rm result`.
9. Service modules reference it as `my.pkgs.<name>`.
10. `just check`; add `just build all` (shared output).

Add `passthru.updateScript` only if the user asks (see `renovate.json`).
