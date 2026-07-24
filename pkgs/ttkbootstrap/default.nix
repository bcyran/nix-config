{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pythonOlder,
  tk,
  setuptools,
  tkinter,
  pillow,
}:
buildPythonPackage rec {
  pname = "ttkbootstrap";
  version = "2.0.1";
  disable = pythonOlder "3.10";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "israel-dryer";
    repo = "ttkbootstrap";
    rev = "refs/tags/v${version}";
    hash = "sha256-SzPD8Z6J9sy7f2eB/mItf329/Wh+sESmhxDJ7v3CP1c=";
  };

  buildsystem = [
    "setuptools"
  ];

  buildInputs = [
    setuptools
    tk
  ];

  propagatedBuildInputs = [
    tkinter
    pillow
  ];

  meta = {
    description = "A supercharged theme extension for tkinter that enables on-demand modern flat style themes inspired by Bootstrap.";
    homepage = "https://github.com/israel-dryer/ttkbootstrap";
    license = lib.licenses.mit;
  };
}
