{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  btrfs-progs,
  pytestCheckHook,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "btrsync";
  version = "0.3-unstable-2026-07-27";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "bcyran";
    repo = "btrsync";
    rev = "f0211992a0925f13f27c8160061b8ed9f383602f";
    hash = "sha256-wy8RlpBr+p9G59awH2BmgAM15ewlU5zEAgIYuUJugks=";
  };

  build-system = [ setuptools ];

  propagatedBuildInputs = [ btrfs-progs ];

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "btrsync" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Btrfs replication made easy (testing dev branch)";
    homepage = "https://github.com/bcyran/btrsync";
    changelog = "https://github.com/bcyran/btrsync/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    mainProgram = "btrsync";
    maintainers = with lib.maintainers; [ bcyran ];
  };
}
