{ sources ? import ./nix/sources.nix }:
let
  pkgs = import sources.nixpkgs { config = {}; overlays = []; };
  build = pkgs.callPackage ./build.nix { };
in
{
  inherit build;
  shell = pkgs.mkShellNoCC {
    inputsFrom = [ build ];
    packages = with pkgs; [
      niv
    ];

    hardeningDisable = ["all"];
  };
}
