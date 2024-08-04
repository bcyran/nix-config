{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "kidex";
  version = "v0.1.1";

  src = fetchFromGitHub {
    owner = "Kirottu";
    repo = pname;
    rev = version;
    hash = "sha256-LgY4hYJOzGSNZxOK1O4L6A+4/qgv4dhouKo0nLKK25A=";
  };

  cargoHash = "sha256-3oSRdXuFThJ8RBsUwwgqkadJKwK53FyTvVfO6PZaDLw=";

  meta = with lib; {
    description = "A simple file indexing service for looking up file locations ";
    homepage = "https://github.com/Kirottu/kidex";
    license = licenses.gpl3Only;
    mainProgram = pname;
  };
}
