{ sources ? import ./nix/sources.nix }:
let
  pkgs = import sources.nixpkgs { config = {}; overlays = []; };
  defaultBuild = pkgs.callPackage ./build.nix { };
  staticBuild = pkgs.callPackage ./build.nix { stdenv = pkgs.pkgsStatic.stdenv; };
  winBuild = pkgs.callPackage ./build.nix { stdenv = pkgs.pkgsCross.ucrt64.stdenv; };
  debugBuild = defaultBuild.overrideAttrs (oldAttrs: { buildInputs = oldAttrs.buildInputs ++ [pkgs.gdb]; });
  shell = pkgs.mkShell {
    inputsFrom = [ defaultBuild ];
    packages = with pkgs; [
      niv
    ];

    hardeningDisable = ["all"];
  };
in
{
  inherit defaultBuild staticBuild debugBuild shell winBuild;
}
