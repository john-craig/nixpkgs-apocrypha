{ lib
, rustPlatform
, fetchFromGitHub
, libusb1
, pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "es2button";
  version = "0.1.0-unstable-2026-08-21";

  src = fetchFromGitHub {
    owner = "janrueth";
    repo = "es2button";
    rev = "624df7ac087cd7e3ca5ca79d7e811c68e5fca8d5";
    hash = "sha256-+Qzm1B6LecSnnwaQ9e4cIZTgLJCGUBY+RvngK1bHVuc=";
  };

  cargoHash = "sha256-6SDSIVuhuSr/ERxd6EF4Y3KLIeK2Hue4sdZ1XlPbapY=";
  buildAndTestSubdir = "es2button";

  nativeBuildInputs = [ pkg-config rustPlatform.bindgenHook ];
  buildInputs = [ libusb1 ];

  passthru.cargoHash = cargoHash;

  meta = {
    description = "Use buttons on Epson scanners through Epson Scan 2";
    homepage = "https://github.com/janrueth/es2button";
    license = lib.licenses.mit;
    mainProgram = "es2button";
    platforms = lib.platforms.linux;
  };
}
