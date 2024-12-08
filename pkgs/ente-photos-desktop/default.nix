{
  appimageTools,
  lib,
  fetchurl,
}: let
  pname = "ente-photos-desktop";
  version = "1.7.5";
  shortName = "ente";
  applicationName = "Ente Photos";
  name = "${shortName}-${version}";

  mirror = "https://github.com/ente-io/photos-desktop/releases/download";
  src = fetchurl {
    url = "${mirror}/v${version}/${name}-x86_64.AppImage";
    hash = "sha256-AV2LJv/xjkeP8BkE5Whm8UlRPUqxWBjfkmpFu08NG4M=";
  };

  appimageContents = appimageTools.extractType2 {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/${shortName}.desktop $out/share/applications/${pname}.desktop
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace 'Exec=AppRun' "Exec=$out/bin/${pname}"
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace 'Name=ente' "Name=${applicationName}"
      cp -r ${appimageContents}/usr/share/icons $out/share
    '';

    meta = with lib; {
      description = "Fully open source, End to End Encrypted alternative to Google Photos and Apple Photos";
      mainProgram = "ente-photos-desktop";
      homepage = "https://github.com/ente-io/photos-desktop";
      license = licenses.mit;
      platforms = ["x86_64-linux"];
    };
  }
