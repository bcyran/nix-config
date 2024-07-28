{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  git,
}:
rustPlatform.buildRustPackage rec {
  pname = "git-chain";
  version = "83e3cdd15025ba7f4f04d8a61678b3ca5c7213a8";

  src = fetchFromGitHub {
    owner = "dashed";
    repo = pname;
    rev = version;
    hash = "sha256-394q3GgSF64wCwkmy/HCm1W/+mao1+wbjvkXzMg9L+s=";
  };

  cargoHash = "sha256-F9hx6OslpQZOUYrHLYvy+sgrjVhAf/VIMX9FL82fu7Q=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  nativeCheckInputs = [
    git
  ];

  meta = with lib; {
    description = "Tool for rebasing a chain of local git branches.";
    homepage = "https://github.com/dashed/git-chain";
    license = licenses.mit;
    mainProgram = pname;
  };
}
