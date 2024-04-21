{ sources ? import ./nix/sources.nix }:
let
  pkgs = import sources.nixpkgs { config = {}; overlays = []; };
  defaultBuild = pkgs.callPackage ./build.nix { };
  staticBuild = pkgs.callPackage ./build.nix { stdenv = pkgs.pkgsStatic.stdenv; };
in
{
  inherit defaultBuild;
  inherit staticBuild;
  shell = pkgs.mkShellNoCC {
    inputsFrom = [ defaultBuild ];
    packages = with pkgs; [
      niv
    ];

    hardeningDisable = ["all"];
  };
}
