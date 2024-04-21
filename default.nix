{ sources ? import ./nix/sources.nix }:
let
  pkgs = import sources.nixpkgs { config = {}; overlays = []; };
  defaultBuild = pkgs.callPackage ./build.nix { };
  staticBuild = pkgs.callPackage ./build.nix { stdenv = pkgs.pkgsStatic.stdenv; };
  debugBuild = defaultBuild.overrideAttrs (oldAttrs: { buildInputs = oldAttrs.buildInputs ++ [pkgs.gdb]; });
in
{
  inherit defaultBuild;
  inherit staticBuild;
  inherit debugBuild;
  shell = pkgs.mkShell {
    inputsFrom = [ defaultBuild ];
    packages = with pkgs; [
      niv
    ];

    hardeningDisable = ["all"];
  };
}
