{ lib, config, ... }:
let
  inherit (lib) mkOption types;
in
{
  _class = "service";

  options = {
    launchd = {
      services = mkOption {
        default = { };
        type = types.lazyAttrsOf (types.deferredModuleWith { });
        description = ''
          Free-form launchd plist keys merged verbatim into the generated
          plist. This is the platform escape hatch for anything that has no
          portable analogue (for example `StartCalendarInterval` or
          `LimitLoadToSessionType`).

          Mirrors the `systemd.*` namespace on NixOS: upstream service modules
          guard these keys with
          `lib.optionalAttrs (options ? systemd) { systemd.* = ...; }`, and the
          same pattern applies here with `launchd` in place of `systemd`.
        '';
      };
    };

    # Recurse this extension into sub-services so the same options are
    # available at every depth.
    services = mkOption {
      type = types.attrsOf (
        types.submoduleWith {
          class = "service";
          modules = [ ./extra-root.nix ];
        }
      );
    };
  };
}
