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
  pname = "ttkboostrap";
  version = "1.10.1";
  disable = pythonOlder "3.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "israel-dryer";
    repo = "ttkbootstrap";
    rev = "refs/tags/v${version}";
    hash = "sha256-aUqr30Tgz3ZLjLbNIt9yi6bqhXj+31heZoOLOZHYUiU=";
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
