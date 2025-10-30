{ lib, inputs, config, ... }:
{
  imports = [
    ./hyprland.nix
    ./wireguard.nix
    ./winboat.nix
    ./docker.nix
    "${inputs.home-manager}/nixos"
  ];

  options.cos = {
    username = lib.mkOption {
      type = lib.types.str;
    };
    knownHosts = lib.mkOption {
      default = [ "loadedskypotato" "clhickey-nixos" "nixnas" "phone" "desktop" ];
      type = lib.types.listOf lib.types.str;
    };
    knownPublicIPs = lib.mkOption {
      type = lib.types.submodule {
        options = lib.attrsets.genAttrs config.cos.knownHosts (name: lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        });
      };
    };
    hostName = lib.mkOption {
      type = lib.types.enum config.cos.knownHosts;
    };
  };

  config.cos = {
    knownPublicIPs = {
      loadedskypotato = "50.116.49.95";
    };
    wireguard.clientPubOptionsMap = {
      "loadedskypotato" = {
        clientNumber = 1;
        publicKey = "raOzdkhoag+sN2/KXz18F9ncmeTWhdmPJxQJkqsJ7FI=";
      };
      "clhickey-nixos" = {
        clientNumber = 3;
        publicKey = "7Hi/p1DEnAejX5vf46ul1ZWAeGM9nuWWGXXr9f6sUWA=";
      };
      "nixnas" = {
        clientNumber = 2;
        publicKey = "TnuODb+I5wfF6z5wlwOFiRr4CKImY557OIXyZCXPSio=";
      };
      "phone" = {
        clientNumber = 4;
        publicKey = "UAP8/k1zWInrksQQAf0NuDUD1b0K0djDVUcYl+DNMEE=";
      };
      "desktop" = {
        clientNumber = 5;
        publicKey = "w054mlSBBq4u0ilTYfwc2xbb5Z+7kEigikSZ3R0u73w=";
      };
    };
  };
}
