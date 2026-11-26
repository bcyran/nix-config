{
  lib,
  fetchFromGitHub,
  makeWrapper,
  python314Packages,
  mcp,
  httpx,
  uvicorn,
}:
python314Packages.buildPythonApplication rec {
  pname = "joplin-server-mcp";
  version = "unstable-2026-11-14";

  src = fetchFromGitHub {
    owner = "Alexander-Zhukov";
    repo = "joplin-server-mcp";
    rev = "742e0e7cb4526f3256da29c217fb250481389609";
    hash = "sha256-XtO7M5xmixzsVjad6NAhUi6UetfUUsJ/LjZuJmRlWu4=";
  };

  pyproject = false;
  dontBuild = true;

  nativeBuildInputs = [makeWrapper];

  # Upstream pins mcp 1.x; 2.x changed the FastMCP API.
  dependencies = [mcp httpx uvicorn];

  installPhase = ''
    runHook preInstall

    install -Dm644 app/server.py $out/share/joplin-server-mcp/server.py
    # makeWrapper bypasses buildPythonApplication's automatic PYTHONPATH wrapping.
    makeWrapper ${python314Packages.python.interpreter} $out/bin/joplin-server-mcp \
      --add-flags "$out/share/joplin-server-mcp/server.py" \
      --set PYTHONPATH "${python314Packages.makePythonPath [mcp httpx uvicorn]}"

    runHook postInstall
  '';

  meta = {
    description = "MCP server for the Joplin Server REST API";
    homepage = "https://github.com/Alexander-Zhukov/joplin-server-mcp";
    license = lib.licenses.mit;
    mainProgram = "joplin-server-mcp";
  };
}
