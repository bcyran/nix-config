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
  version = "1.1.16";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "louwrentius";
    repo = "fio-plot";
    rev = "9484287";
    hash = "sha256-yN0gVm6ZYEIoh91d+0ohJ9yU+VWwYEq3MoG+WgBrs2Q=";
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
