{
  lib,
  python3,
  fetchFromGitHub,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "wyoming-openai-gateway";
  version = "0.2.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Archmonger";
    repo = "Wyoming-OpenAI-Gateway";
    rev = "v${version}";
    hash = "sha256-b2cRahoUplebEo6tEDnOQKBuA6rn23LPxjb//nGNWR8=";
  };

  build-system = with python3.pkgs; [hatchling];

  dependencies = with python3.pkgs; [
    fastapi
    miniaudio
    pydantic
    python-multipart
    uvicorn
    wyoming
  ];

  pythonImportsCheck = ["wyoming_openai_gateway"];

  meta = {
    description = "OpenAI-compatible API gateway for Wyoming speech services";
    homepage = "https://github.com/Archmonger/Wyoming-OpenAI-Gateway";
    license = lib.licenses.mit;
    mainProgram = "wyoming-openai-gateway";
  };
}
