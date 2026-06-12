{
  lib,
  buildNpmPackage,
  fetchzip,
  git,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  nodejs_22,
  opencode,
  openssh,
}:
buildNpmPackage (finalAttrs: {
  pname = "openchamber";
  version = "1.12.4";
  nodejs = nodejs_22;

  desktopItems = [
    (makeDesktopItem {
      name = "openchamber";
      desktopName = "OpenChamber";
      genericName = "OpenCode Web UI";
      comment = "Desktop and web interface for OpenCode";
      exec = "openchamber";
      terminal = false;
      categories = [
        "Development"
        "Utility"
      ];
      icon = "openchamber";
      startupNotify = true;
    })
  ];

  src = fetchzip {
    url = "https://registry.npmjs.org/@openchamber/web/-/web-${finalAttrs.version}.tgz";
    hash = "sha256-lP3dDj1iwW43N6G4m9OqSHxctC1ioMqiMj/DUHbLrnY=";
    stripRoot = false;
  };

  prePatch = ''
    if [ -d package ]; then
      cp -r package/. .
      chmod -R u+w .
      rm -rf package
    fi
  '';

  npmDepsHash = "sha256-PUIjdTBwsQFlZHReJMLaLzYIhnJvgtolQapJ2ykBahQ=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  npmFlags = [
    "--no-audit"
    "--no-fund"
  ];

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  propagatedBuildInputs = [opencode];

  postInstall = ''
    install -Dm644 dist/pwa-512.png \
      $out/share/icons/hicolor/512x512/apps/openchamber.png

    wrapProgram $out/bin/openchamber \
      --prefix PATH : ${lib.makeBinPath [
        git
        openssh
        opencode
      ]} \
      --set DISABLE_AUTOUPDATER 1 \
      --set npm_config_update_notifier false
  '';

  meta = {
    description = "Desktop and web interface for OpenCode AI agent";
    homepage = "https://github.com/openchamber/openchamber";
    downloadPage = "https://www.npmjs.com/package/@openchamber/web";
    license = lib.licenses.mit;
    mainProgram = "openchamber";
    platforms = lib.platforms.linux;
  };
})
