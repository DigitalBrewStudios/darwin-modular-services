{
  description = "Support for modular services in nix-darwin";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
    }:
    let
      forDarwinSystems = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
      ];
    in
    {
      darwinModules.default = {
        imports = [
          ./modules/system.nix
          ./modules/user.nix
        ];
      };

      checks = forDarwinSystems (
        system:
        import ./tests {
          inherit nixpkgs system nix-darwin;
          shim = self.darwinModules.default;
        }
      );
    };
}
