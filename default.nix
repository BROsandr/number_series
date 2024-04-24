{ sources ? import ./nix/sources.nix }:
let
  all_builds = (import ./all_builds.nix) { inherit sources; };
in
{
  inherit (all_builds.linuxBuild) shared;
}
