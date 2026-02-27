{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  python3,
}:
buildNpmPackage rec {
  pname = "bentopdf";
  version = "2.3.3";

  src = fetchFromGitHub {
    owner = "alam00000";
    repo = "bentopdf";
    rev = "v${version}";
    hash = "sha256-Flp9uIIcuoBjEfTID9kPI5fkGIIb9NvA0FNEesuj1fE=";
  };

  npmDepsHash = "sha256-DsWH0RmGOIRIimp6rKt8b5PPaaaDU1jNdM/javA3sB8=";

  env.HUSKY = "0";
  env.NODE_OPTIONS = "--max-old-space-size=3072";
  env.SIMPLE_MODE = "true";

  makeCacheWritable = true;

  # The vendored embedpdf-snippet uses a file: protocol reference in
  # package-lock.json which nix's npm dependency fetcher cannot resolve.
  # Remove it and all its exclusive transitive deps from the lockfile.
  # We manually extract the tarball into node_modules after npm ci.
  postPatch = let
    patchFiles = ''
      import json

      with open("package-lock.json", "r") as f:
          lock = json.load(f)

      # Remove embedpdf-snippet and all @embedpdf/* packages,
      # plus packages only present due to react/react-dom overrides
      exclusive_deps = {"react", "react-dom", "scheduler", "loose-envify"}
      to_remove = []
      for key in lock["packages"]:
          name = key.replace("node_modules/", "", 1)
          if name.startswith("embedpdf-snippet") or name.startswith("@embedpdf/"):
              to_remove.append(key)
          elif name in exclusive_deps:
              to_remove.append(key)

      for key in to_remove:
          lock["packages"].pop(key, None)

      root = lock["packages"].get("", {})
      root.get("dependencies", {}).pop("embedpdf-snippet", None)

      with open("package-lock.json", "w") as f:
          json.dump(lock, f, indent=2)

      with open("package.json", "r") as f:
          pkg = json.load(f)
      pkg.get("dependencies", {}).pop("embedpdf-snippet", None)
      pkg.get("overrides", {}).pop("react", None)
      pkg.get("overrides", {}).pop("react-dom", None)
      with open("package.json", "w") as f:
          json.dump(pkg, f, indent=2)
    '';
  in ''
    patchShebangs scripts/
    ${python3}/bin/python3 -c ${lib.escapeShellArg patchFiles}
  '';

  # Manually extract the vendored embedpdf-snippet tarball into node_modules
  # since we can't use npm install in the sandbox (no network access).
  preBuild = ''
    mkdir -p node_modules/embedpdf-snippet
    tar xzf vendor/embedpdf/embedpdf-snippet-2.3.0.tgz -C node_modules/embedpdf-snippet --strip-components=1
  '';

  npmBuildScript = "build";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/bentopdf
    cp -r dist/* $out/share/bentopdf/
    runHook postInstall
  '';

  meta = {
    description = "A privacy-first, client-side PDF toolkit that runs entirely in the browser";
    homepage = "https://github.com/alam00000/bentopdf";
    changelog = "https://github.com/alam00000/bentopdf/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
  };
}
