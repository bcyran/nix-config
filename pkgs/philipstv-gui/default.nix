{
  lib,
  fetchFromGitHub,
  buildPythonApplication,
  pythonOlder,
  poetry-core,
  poetry-dynamic-versioning,
  philipstv,
  appdirs,
  ttkbootstrap,
}:
buildPythonApplication rec {
  pname = "philipstv-gui";
  version = "2.0.0";
  format = "pyproject";
  disable = pythonOlder "3.10";

  src = fetchFromGitHub {
    owner = "bcyran";
    repo = "philipstv-gui";
    rev = "refs/tags/${version}";
    hash = "sha256-Ez8bjbuthdJUDOgIXzGMEyaU86CUadGlUuvOyRPsV+I=";
  };

  nativeBuildInputs = [
    poetry-core
    poetry-dynamic-versioning
  ];

  propagatedBuildInputs = [
    philipstv
    appdirs
    ttkbootstrap
  ];

  meta = {
    description = "GUI remote for Philips Android-powered TVs.";
    homepage = "https://github.com/bcyran/philipstv-gui";
    license = lib.licenses.mit;
    mainProgram = "philipstv-gui";
  };
}
