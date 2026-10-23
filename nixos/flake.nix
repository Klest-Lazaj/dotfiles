{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      # configuration.nix and hardware-configuration.nix are copied from the
      # laptop's /etc/nixos after install; desktop.nix is everything added on top.
      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./desktop.nix
        ];
      };
    };
}
