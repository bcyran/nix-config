{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  makeWrapper,
}:
buildNpmPackage rec {
  pname = "koinsight";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "GeorgeSG";
    repo = "KoInsight";
    rev = "v${version}";
    hash = "sha256-hXJcEBIXi+N/nis6xM7NZ53E53Fv8KZr3/oPHbT4GSw=";
  };

  npmDepsHash = "sha256-W6BW/1ToRvkWAkhM/0gAS4fqKWjB01I5jV6aEk5r1YU=";

  nativeBuildInputs = [makeWrapper];

  preBuild = ''
    patchShebangs packages/common/node_modules
    patchShebangs apps/web/node_modules
    patchShebangs apps/server/node_modules
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/koinsight/apps/{server,web}

    # Copy production node_modules and remove workspace symlinks
    cp -r node_modules $out/share/koinsight/node_modules
    rm -f $out/share/koinsight/node_modules/@koinsight/common
    rm -f $out/share/koinsight/node_modules/web
    rm -f $out/share/koinsight/node_modules/server

    # Copy the built application
    cp -r apps/server/dist $out/share/koinsight/apps/server/dist
    cp -r apps/web/dist $out/share/koinsight/apps/web/dist

    # Copy plugins directory
    cp -r plugins $out/share/koinsight/plugins

    # Create the executable wrapper
    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/koinsight \
      --add-flags "$out/share/koinsight/apps/server/dist/app.js" \
      --set NODE_ENV production \
      --set-default DATA_PATH "/var/lib/koinsight"

    runHook postInstall
  '';

  meta = {
    description = "KoInsight brings your KoReader reading stats to life with a clean, web-based dashboard";
    homepage = "https://github.com/GeorgeSG/KoInsight";
    changelog = "https://github.com/GeorgeSG/KoInsight/releases/tag/v${src.rev}";
    mainProgram = "koinsight";
    license = lib.licenses.mit;
  };
}
