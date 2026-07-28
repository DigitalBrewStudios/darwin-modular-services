# Borrowed from https://github.com/nix-darwin/nix-darwin/blob/master/release.nix
{
  nixpkgs ? <nixpkgs>,
  # Adapted from https://github.com/NixOS/nixpkgs/blob/e818264fe227ad8861e0598166cf1417297fdf54/pkgs/top-level/release.nix#L11
  nix-darwin ? <nix-darwin>,
  shim ? { },
  system ? builtins.currentSystem,
}:
let
  buildFromConfig =
    configuration: sel:
    sel (import "${nix-darwin}/default.nix" { inherit nixpkgs configuration system; }).config;
  makeTest =
    test:
    let
      testName = builtins.replaceStrings [ ".nix" ] [ "" ] (baseNameOf test);

      configuration =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        with lib;
        {
          imports = [
            test
            shim
          ];

          options = {
            out = mkOption {
              type = types.package;
            };

            test = mkOption {
              type = types.lines;
            };
          };

          config = {

            system.stateVersion = lib.mkDefault config.system.maxStateVersion;

            system.build.run-test =
              pkgs.runCommand "darwin-test-${testName}"
                {
                  allowSubstitutes = false;
                  preferLocalBuild = true;
                }
                ''
                  #! ${pkgs.stdenv.shell}
                  set -e

                  echo >&2 "running tests for system ${config.out}"
                  echo >&2
                  ${config.test}
                  echo >&2 ok
                  touch $out
                '';

            out = config.system.build.toplevel;
          };
        };
    in
    buildFromConfig configuration (config: config.system.build.run-test);
in
{
  services-modular-basic = makeTest ./basic.nix;
  services-modular-configdata = makeTest ./configData.nix;
  services-modular-user-agent = makeTest ./userAgent.nix;
  services-modular-upstream-eval = makeTest ./upstream-eval.nix;
  services-modular-upstream = makeTest ./upstream.nix;
}
