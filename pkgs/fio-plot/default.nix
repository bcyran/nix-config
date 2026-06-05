{
  lib,
  fetchFromGitHub,
  buildPythonApplication,
  setuptools,
  numpy,
  matplotlib,
  pillow,
  pyparsing,
  rich,
}:
buildPythonApplication {
  pname = "fio-plot";
  version = "1.1.21";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "louwrentius";
    repo = "fio-plot";
    rev = "cfc6a6f6e6f0de13838ea7cdb8861fdc07f42185";
    hash = "sha256-iEn6BlfDRZK9vSnx5EEJpjiV61OEU3fHeZMaTYd4X5Q=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail ", \"pyan3\"" "" \
      --replace-fail 'scripts=["bin/fio-plot", "bin/bench-fio"],' ""
  '';

  build-system = [setuptools];

  propagatedBuildInputs = [
    setuptools
    numpy
    matplotlib
    pillow
    pyparsing
    rich
  ];

  meta = {
    description = "Create charts from FIO storage benchmark tool output ";
    homepage = "https://github.com/louwrentius/fio-plot";
    license = lib.licenses.bsd3;
    mainProgram = "fio-plot";
  };
}
