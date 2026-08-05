{ lib, fetchFromGitHub, python313Packages }:

python313Packages.buildPythonPackage rec {
  pname = "lshell";
  version = "0.10.10";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "ghantoos";
    repo = "lshell";
    rev = "bf84e22f7f53d0a2f3ed2e2c008941206c0003f3";
    hash = "sha256-npPSAY+EPmxUQnkO9D2byX2i7sAbgAQKFmOiOqdbXLQ=";
  };

  propagatedBuildInputs = with python313Packages; [
    psutil
    pyyaml
  ];

  preBuild = ''
    export HOME="$TMPDIR"
  '';

  preInstall = ''
    export HOME="$TMPDIR"
  '';

  pythonImportsCheck = [ "lshell" ];

  meta = with lib; {
    description = "Limited shell with fine-grained command allow-listing";
    homepage = "https://github.com/ghantoos/lshell";
    license = licenses.gpl2Only;
    mainProgram = "lshell";
  };
}
