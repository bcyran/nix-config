{
  lib,
  fetchFromGitHub,
  rustPlatform,
  installShellFiles,
  makeWrapper,
  fuzzyMatcherPackage ? fzf,
  fzf,
}:
rustPlatform.buildRustPackage rec {
  pname = "git-smash";
  version = "v0.1.1";

  src = fetchFromGitHub {
    owner = "anthraxx";
    repo = pname;
    rev = version;
    hash = "sha256-NyNYEF5g0O9xNhq+CoDPhQXZ+ISiY4DsShpjk5nP0N8=";
  };

  cargoHash = "sha256-D4ncbhJgn32x80q7TpR3GhSaSBcJlDlGH+Fflf4ULRQ=";

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  postFixup = ''
    wrapProgram "$out/bin/$pname" --prefix PATH : "${fuzzyMatcherPackage}/bin"
  '';

  postInstall = ''
    installShellCompletion --cmd $pname \
      --bash <($out/bin/$pname completions bash) \
      --fish <($out/bin/$pname completions fish) \
      --zsh <($out/bin/$pname completions zsh)
  '';

  meta = with lib; {
    description = "Smash staged changes into previous commits to support your Git workflow, pull request and feature branch maintenance.";
    homepage = "https://github.com/anthraxx/git-smash";
    license = licenses.mit;
    mainProgram = pname;
  };
}
