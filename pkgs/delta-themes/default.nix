{ lib, stdenv, fetchFromGitHub }:
let
  pname = "delta-themes";
  version = "0.16.5";
  revision = "03f1569a9aff964e9291371d9928d0584327eae2";
in
stdenv.mkDerivation {
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "dandavison";
    repo = "delta";
    rev = "${revision}";
    sha256 = "1wydrvckcb7lsl6rs4xfv4xw52vmhnmqcyab8cgw8gyffxyyv9av";
  };

  buildPhase = "true";

  installPhase = ''
    install -Dm 445 $src/themes.gitconfig -t $out/share
  '';

  meta = with lib; {
    description = "Delta themes";
    longDescription = "Themes for git diff syntax highlighting tool";
    homepage = "https://github.com/dandavison/delta";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
