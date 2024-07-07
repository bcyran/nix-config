{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pythonOlder,
  poetry-core,
  poetry-dynamic-versioning,
  installShellFiles,
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
    installShellFiles
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

  postInstall = ''
    installShellCompletion --cmd philipstv \
      --bash <(_PHILIPSTV_COMPLETE=bash_source $out/bin/philipstv) \
      --zsh <(_PHILIPSTV_COMPLETE=zsh_source $out/bin/philipstv) \
      --fish <(_PHILIPSTV_COMPLETE=fish_source $out/bin/philipstv)
  '';

  meta = with lib; {
    description = "CLI and library to control Philips Android-powered TVs.";
    homepage = "https://github.com/bcyran/philipstv";
    license = licenses.mit;
    mainProgram = "philipstv";
  };
}
