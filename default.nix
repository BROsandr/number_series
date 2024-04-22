{ sources ? import ./nix/sources.nix }:
let
  pkgs = import sources.nixpkgs { config = {}; overlays = []; };
  defaultBuild = pkgs.callPackage ./build.nix { };
  releaseBuild = defaultBuild.overrideAttrs (oldAttrs: { mesonBuildType = "release"; });
  debugBuild = defaultBuild.overrideAttrs (oldAttrs: { mesonBuildType = "debug"; });
  staticBuild = releaseBuild.override { stdenv = pkgs.pkgsStatic.stdenv; };
  forLinkage = pkgs: drv: {
    shared = drv.override { stdenv = pkgs.stdenv; };
    static = drv.override { stdenv = pkgs.pkgsStatic.stdenv; };
  };

  winBuild   = forLinkage pkgs.pkgsCross.ucrt64 releaseBuild;
  linuxBuild = forLinkage pkgs                  releaseBuild;

  # sharedBuild = {
  #   linux = releaseBuild;
  #   win = releaseBuild.override { stdenv = pkgs.pkgsCross.ucrt64.stdenv; };
  # };
  shell = pkgs.mkShell {
    inputsFrom = [ defaultBuild ];
    packages = with pkgs; [
      niv
      pkgs.gdb
    ];

    hardeningDisable = ["all"];
  };
in
{
  inherit winBuild linuxBuild debugBuild shell;
}
