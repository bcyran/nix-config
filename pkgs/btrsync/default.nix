{
  lib,
  fetchFromGitHub,
  buildPythonApplication,
  pythonOlder,
  setuptools,
  btrfs-progs,
  pytestCheckHook,
}:
buildPythonApplication rec {
  pname = "btrsync";
  version = "0.3";
  disable = pythonOlder "3.9";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "andreittr";
    repo = "btrsync";
    rev = "refs/tags/v${version}";
    hash = "sha256-1LpHO70Yli9VG1UeqPZWM2qUMUbSbdgNP/r7FhUY/h4=";
  };

  nativeBuildInputs = [setuptools];
  propagatedBuildInputs = [btrfs-progs];

  nativeCheckInputs = [pytestCheckHook];

  meta = {
    description = "btrfs replication made easy";
    homepage = "https://github.com/andreittr/btrsync";
    changelog = "https://github.com/andreittr/btrsync/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    mainProgram = "btrsync";
  };
}
