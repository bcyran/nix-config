{
  lib,
  buildGoModule,
  fetchFromGitHub,
  buildNpmPackage,
  pkg-config,
  libvirt,
  inter,
  fontforge,
}: let
  version = "1.27.0";

  src = fetchFromGitHub {
    owner = "volantvm";
    repo = "flint";
    rev = "v${version}";
    hash = "sha256-dDGWQdRhKkhLvu+LdE1Z74XIurvRCYaWPQZRvnmXELw=";
  };

  webui = buildNpmPackage {
    pname = "flint-kvm-webui";
    inherit version src;

    sourceRoot = "${src.name}/web";

    npmDepsHash = "sha256-SPwt0yR6sRTwZMtiEuA85Albe+Ckjz481Z49U1sCtiI=";

    patches = [
      ./use-local-fonts.patch
    ];

    nativeBuildInputs = [
      fontforge
    ];

    postPatch = ''
      cp ${./package-lock.json} package-lock.json

      # Create fonts directory and convert Inter fonts to WOFF2
      mkdir -p public/fonts
      cp ${inter}/share/fonts/truetype/InterVariable.ttf public/fonts/
      fontforge -lang=ff -c 'Open($1); Generate($2)' \
        public/fonts/InterVariable.ttf \
        public/fonts/Inter-Variable.woff2

      # Create weight-specific copies (Next.js expects separate files per weight)
      for weight in Regular Medium SemiBold Bold; do
        cp public/fonts/Inter-Variable.woff2 public/fonts/Inter-''${weight}.woff2
      done
    '';

    npmBuildScript = "build";

    env = {
      NEXT_TELEMETRY_DISABLED = "1";
    };

    makeCacheWritable = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r out/* $out/
      runHook postInstall
    '';
  };
in
  buildGoModule {
    pname = "flint-kvm";
    inherit version src;

    vendorHash = "sha256-Fw8hVL14fWiBamTJRrYZWx7eKgQfgdq5EbZLF4I7K8g=";

    nativeBuildInputs = [
      pkg-config
    ];

    buildInputs = [
      libvirt
    ];

    preBuild = ''
      mkdir -p web/out
      cp -r ${webui}/* web/out/
    '';

    ldflags = ["-s" "-w"];

    meta = {
      description = "Lightweight tool for managing linux virtual machines ";
      homepage = "https://github.com/volantvm/flint";
      changelog = "https://github.com/volantvm/flint/releases/tag/${src.rev}";
      license = lib.licenses.asl20;
      mainProgram = "flint";
      platforms = lib.platforms.linux;
    };
  }
