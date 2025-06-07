{pkgs, ...}: let
  sharedLibs = with pkgs; [
    stdenv.cc.cc
  ];
in
  pkgs.mkShell {
    name = "python";

    packages = with pkgs; [
      uv
      pyright
      ruff
    ];

    NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath sharedLibs;
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath sharedLibs;
    TOX_TESTENV_PASSENV = "NIX_LD_LIBRARY_PATH";

    shellHook = ''
      export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

      if [[ ! -d ".venv" ]]; then
        echo "No virtual environment found, creating..."
        uv venv --python-preference only-managed --prompt "$(basename $PWD)" .venv
        source .venv/bin/activate

        echo "Installing tools..."
        uv pip install ptpython

        if [[ -f tox.ini ]]; then
          echo "Found tox.ini, installing tox..."
          uv pip install tox
        fi
      else
        source .venv/bin/activate
      fi

      if [[ -f .noinstall ]]; then
        echo "Skipping requirements installation.";
        return
      elif [[ -f requirements-test.txt ]]; then
        echo "Found requirements-test.txt, installing...";
        uv pip install -r requirements-test.txt
      elif [[ -f requirements.txt ]]; then
        echo "Found requirements.txt, installing...";
        uv pip install -r requirements.txt
      fi

      echo "Virtual environment ready!"
    '';
  }
