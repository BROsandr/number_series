let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/archive/fd16bb6d3bcca96039b11aa52038fafeb6e4f4be.tar.gz"; # unstable channel
  pkgs = import nixpkgs { config = {}; overlays = []; };
in
{
  build = pkgs.callPackage ./build.nix { };
}
