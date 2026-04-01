{
  buildHomeAssistantComponent,
  fetchFromGitHub,
  construct,
  python-miio,
}:
buildHomeAssistantComponent rec {
  owner = "syssi";
  domain = "xiaomi_miio_fan";
  version = "2025.7.0.1";

  src = fetchFromGitHub {
    owner = "syssi";
    repo = "xiaomi_fan";
    rev = version;
    hash = "sha256-+w0OxUn7wKYb+RmG0QowaxP1wBL5Re50t77XQ8iWDzQ=";
  };

  postPatch = ''
    substituteInPlace custom_components/xiaomi_miio_fan/manifest.json \
      --replace-fail "==" ">="
  '';

  dependencies = [
    construct
    python-miio
  ];

  dontBuild = true;

  meta = {
    description = "Xiaomi Mi Smart Fan integration for Home Assistant";
    homepage = "https://github.com/syssi/xiaomi_fan";
  };
}
