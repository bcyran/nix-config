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
  version = "1.2.0";
  format = "pyproject";
  disable = pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "bcyran";
    repo = "philipstv-gui";
    rev = "refs/tags/${version}";
    hash = "sha256-vSU8VB2NbwMGGtNBdJ1M0alttYO1HlGi2bl7WbPDm48=";
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
