{ sources ? import ./nix/sources.nix }:
let
  pkgs = import sources.nixpkgs { config = {}; overlays = []; };
  defaultBuild = pkgs.callPackage ./. { };
  releaseBuild = defaultBuild.overrideAttrs (oldAttrs: { mesonBuildType = "release"; });
  debugBuild = let
    mkDebug = pkgs: build:
      build.overrideAttrs (oldAttrs: rec {
        mesonBuildType = "debug";
        mesonFlags = (oldAttrs.mesonFlags or []) ++ (let inherit (pkgs.lib.strings) mesonBool mesonOption; in [
          (mesonBool   "cpp_debugstl" true)
          (mesonBool   "b_ndebug"     false)
          (mesonOption "b_sanitize"   "address,undefined")
        ]);
        env.CXXFLAGS = (oldAttrs.env.CXXFLAGS or "") + (if pkgs.stdenv.cc.isGNU then pkgs.lib.strings.concatStringsSep " " [
          "-Wshadow"
          "-Wformat=2"
          "-Wfloat-equal"
          "-Wconversion"
          "-Wlogical-op"
          "-Wshift-overflow=2"
          "-Wduplicated-cond"
          "-Wcast-qual"
          "-Wcast-align"
          "-D_GLIBCXX_DEBUG"
          "-D_GLIBCXX_DEBUG_PEDANTIC"
          "-fno-sanitize-recover"
          "-fstack-protector"
          "-Wsign-conversion"
          "-Weffc++"
        ] else "");
        env.CFLAGS = env.CXXFLAGS;
        dontInstall = true;
        dontFixup = true;
        hardeningDisable = ["all"];
      });
  in mkDebug pkgs defaultBuild;
  staticBuild = releaseBuild.override { stdenv = pkgs.pkgsStatic.stdenv; };
  forLinkage = pkgs: drv: {
    shared = drv.override { stdenv = pkgs.stdenv; };
    static = drv.override { stdenv = pkgs.pkgsStatic.stdenv; };
  };

  winBuild.shared = releaseBuild.override { stdenv = pkgs.pkgsCross.ucrt64.stdenv; };
  linuxBuild      = forLinkage pkgs                  releaseBuild;

  shell = pkgs.mkShell {
    inputsFrom = [ debugBuild ];
    packages = with pkgs; [
      niv
      gdb
      clang-tools
      clang
    ];

    shellHook = ''
      eval "
      setupBuilder() {
        rm -rf source
        nix-shell all_builds.nix -A debugBuild --pure
      }
      "
    '';

    hardeningDisable = ["all"];
  };
in
{
  inherit defaultBuild winBuild linuxBuild debugBuild shell;
}
