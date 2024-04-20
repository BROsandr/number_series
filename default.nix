{ sources ? import ./nix/sources.nix }:
let
  pkgs = import sources.nixpkgs { config = {}; overlays = []; };
in
{
  build = pkgs.callPackage ./build.nix { };
}
