{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "sceptre";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "john-craig";
    repo = "sceptre";
    rev = "40fcc69d2bc38963081858d37db7be2f2ebcd554";
    hash = "sha256-5n0DhQxfMilPdJPuQEoecQ/912rQM37+WgRMs54MaZM=";
  };

  cargoLock.lockFile = "${src}/Cargo.lock";

  postInstall = ''
    mv "$out/bin/rust-template" "$out/bin/sceptre"
  '';

  meta = with lib; {
    description = "Rust CLI for Grimoire development workflows";
    homepage = "https://github.com/john-craig/sceptre";
    license = licenses.mit;
    mainProgram = "sceptre";
    platforms = platforms.unix;
  };
}
