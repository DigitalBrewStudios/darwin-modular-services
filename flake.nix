{
  description = "Support for modular services in nix-darwin";

  outputs = _: {
    darwinModules.default = {
      imports = [
        ./modules/system.nix
        ./modules/user.nix
      ];
    };
  };
}
