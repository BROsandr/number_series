let
  pkgs = import <nixpkgs> { config = {}; overlays = []; };
in
{
  build = pkgs.callPackage ./build.nix { };
}
