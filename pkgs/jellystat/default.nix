{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  makeWrapper,
}:
buildNpmPackage rec {
  pname = "jellystat";
  version = "1.1.8";

  src = fetchFromGitHub {
    owner = "CyferShepard";
    repo = "Jellystat";
    rev = "V${version}";
    hash = "sha256-3wD9xy+P/edVJnLgImRyDCQ1xgVvkjN07T5JZDoJFY0=";
  };

  npmDepsHash = "sha256-Y40ZnpHjEbYOjDrgwjLxCTyGWHGH6Zw8JADUiJc4hl4=";

  makeCacheWritable = true;
  npmFlags = ["--legacy-peer-deps"];

  nativeBuildInputs = [makeWrapper];

  postPatch = ''
    substituteInPlace backend/server.js \
      --replace-fail "const PORT = 3000;" "const PORT = process.env.JS_LISTEN_PORT || 3000;"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/jellystat
    cp -r dist $out/share/jellystat/dist
    cp -r backend $out/share/jellystat/backend
    cp -r node_modules $out/share/jellystat/node_modules
    cp package.json $out/share/jellystat/package.json

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/jellystat \
      --add-flags "$out/share/jellystat/backend/server.js" \
      --set NODE_ENV production \
      --chdir "$out/share/jellystat/backend"

    runHook postInstall
  '';

  meta = {
    description = "A free and open source statistics app for Jellyfin";
    homepage = "https://github.com/CyferShepard/Jellystat";
    changelog = "https://github.com/CyferShepard/Jellystat/releases/tag/V${version}";
    mainProgram = "jellystat";
    license = lib.licenses.mit;
  };
}
