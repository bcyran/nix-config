{
  lib,
  fetchFromGitHub,
  rustPlatform,
  installShellFiles,
  libheif,
}:
rustPlatform.buildRustPackage rec {
  pname = "timewall";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "bcyran";
    repo = pname;
    rev = version;
    hash = "sha256-AdT/+88I27a0mdYOgFp1NvRS89dA2lZ1GyucZ0/0Jjg=";
  };

  cargoHash = "sha256-oVHQaUnw7n+BwXcIB/2aS/zD160mCgYsSHrm/Cc4sr4=";

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = [
    libheif
  ];

  SHELL_COMPLETIONS_DIR = "completions";

  preBuild = ''
    mkdir ${SHELL_COMPLETIONS_DIR}
  '';

  postInstall = ''
    installShellCompletion \
      --bash ${SHELL_COMPLETIONS_DIR}/${pname}.bash \
      --zsh ${SHELL_COMPLETIONS_DIR}/_${pname} \
      --fish ${SHELL_COMPLETIONS_DIR}/${pname}.fish
  '';

  meta = with lib; {
    description = "Apple dynamic HEIF wallpapers on GNU/Linux.";
    homepage = "https://github.com/bcyran/timewall";
    license = licenses.mit;
    mainProgram = "timewall";
  };
}
