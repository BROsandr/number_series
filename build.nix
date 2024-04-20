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

  buildInputs = with pkgs; [
    meson
    ninja
  ];

  configurePhase = ''
    runHook preConfigure
    mkdir -p build
    meson setup build
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    meson compile -C build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ./build/number_series* $out/bin
    runHook postInstall
  '';
}
