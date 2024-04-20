{
  lib,
  stdenv,
  pkgs,
}:
let
  fs = lib.fileset;
  sourceFiles = fs.unions [./src ./inc ./meson.build];
in

stdenv.mkDerivation {
  pname = "number_series";
  version = "v1.3.0";

  src = fs.toSource {
    root = ./.;
    fileset = sourceFiles;
  };

  nativeBuildInputs = with pkgs; [
    meson
    ninja
  ];
}
