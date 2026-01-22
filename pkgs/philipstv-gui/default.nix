{
  lib,
  fetchFromGitHub,
  buildPythonApplication,
  pythonOlder,
  hatchling,
  hatch-vcs,
  philipstv,
  appdirs,
  ttkbootstrap,
}:
buildPythonApplication rec {
  pname = "philipstv-gui";
  version = "2.0.1";
  format = "pyproject";
  disable = pythonOlder "3.10";

  src = fetchFromGitHub {
    owner = "bcyran";
    repo = "philipstv-gui";
    rev = "refs/tags/${version}";
    hash = "sha256-qV+xetWziE9ORkIk93gXl3Q5+zCnLKJho28RztlIzrE=";
  };

  nativeBuildInputs = [
    hatchling
    hatch-vcs
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
