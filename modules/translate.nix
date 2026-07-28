# Portable serviceSubmodule -> launchd entry translation, shared between
# the system (`launchd.daemons`) and user (`launchd.user.agents`) trees.
{ lib }:
let
  inherit (lib)
    concatMapAttrs
    ;

  dash =
    before: after:
    if after == "" then
      before
    else if before == "" then
      after
    else
      "${before}-${after}";

  # Walk a service (and its sub-services) producing a flat attrset of
  # launchd-entry configs keyed by dashed service path.
  flatten =
    let
      go =
        prefix: service:
        {
          ${prefix} = {
            command = lib.escapeShellArgs service.process.argv;
            serviceConfig = service.launchd.services or { };
          };
        }
        // concatMapAttrs (n: sub: go (dash prefix n) sub) (service.services or { });
    in
    go;
in
{
  inherit dash flatten;
}
