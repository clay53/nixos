{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    penn-nix.url = "github:clay53/penn-nix";
    cnvim = {
      url = "github:clay53/cnvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #mapnix = {
    #  url = "path:/home/clhickey/osm-biking-filter/mapnik/flake.nix";
    #};
  };
  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.clhickey-nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        /home/clhickey/osm-biking-filter/mapnik/flake.nix
      ];
    };
  };
}

