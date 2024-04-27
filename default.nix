{
  lib,
  stdenv,
  pkgs,
  meson,
  ninja,
  sourceFiles ? lib.fileset.unions [./src ./inc ./meson.build],
}:
let
  fs = pkgs.lib.fileset;
in

stdenv.mkDerivation {
  pname = "number_series";
  version = "v1.3.0";

  src = fs.toSource {
    root = ./.;
    fileset = sourceFiles;
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [ ];
}
