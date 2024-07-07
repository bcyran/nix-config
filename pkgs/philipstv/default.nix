{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pythonOlder,
  poetry-core,
  poetry-dynamic-versioning,
  pytestCheckHook,
  requests-mock,
  requests,
  pydantic,
  click,
  appdirs,
}:
buildPythonPackage rec {
  pname = "philipstv";
  version = "2.1.1";
  format = "pyproject";
  disable = pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "bcyran";
    repo = "philipstv";
    rev = "refs/tags/${version}";
    hash = "sha256-BvQurZls9NjtHhTXLQ9t8fHkAF/QU/c6mmRvNmE0v90=";
  };

  nativeBuildInputs = [
    poetry-core
    poetry-dynamic-versioning
  ];

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  propagatedBuildInputs = [
    requests
    pydantic
    click
    appdirs
  ];

  meta = with lib; {
    description = "CLI and library to control Philips Android-powered TVs.";
    homepage = "https://github.com/bcyran/philipstv";
    license = licenses.mit;
    mainProgram = "philipstv";
  };
}
