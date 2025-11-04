{ lib, config, ... }:
let cfg = config.cos.remoteBuild; in
{
  options.cos.remoteBuild = {
    enable = lib.mkEnableOption "Turn on remote builders";
  };

  config = lib.mkIf cfg.enable {
    cos.wireguard.enable = true;

    nix.buildMachines = [{
      sshUser = "clhickey";
      hostName = config.cos.wireguard.clientPubOptionsMap.nixnas.ip;
      system = "x86_64-linux";
      protocol = "ssh-ng";
      maxJobs = 4;
      speedFactor = 1;
      supportedFeatures = [ "kvm" "nixos-tests" "big-parallel" ];
      mandatoryFeatures = [];
    }];
    nix.distributedBuilds = true;
    nix.settings.builders-use-substitutes = false;
  };
}
