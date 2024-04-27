{ sources ? import ./nix/sources.nix }:
let
  pkgs = import sources.nixpkgs { config = {}; overlays = []; };
  defaultBuild = pkgs.callPackage ./. { };
  releaseBuild = defaultBuild.overrideAttrs (oldAttrs: { mesonBuildType = "release"; });
  staticBuild = releaseBuild.override { stdenv = pkgs.pkgsStatic.stdenv; };
  forLinkage = pkgs: drv: {
    shared = drv.override { stdenv = pkgs.stdenv; };
    static = drv.override { stdenv = pkgs.pkgsStatic.stdenv; };
  };

  winBuild.shared = releaseBuild.override { stdenv = pkgs.pkgsCross.ucrt64.stdenv; };
  linuxBuild      = forLinkage pkgs                  releaseBuild;

  shell = pkgs.mkShell {
    inputsFrom = [ defaultBuild ];
    packages = with pkgs; [
      niv
      gdb
      clang-tools
      clang-analyzer
      clang
    ];

    hardeningDisable = ["all"];
  };
in
{
  inherit defaultBuild winBuild linuxBuild shell;
}
