{ lib, config, ... }:
let cfg = config.cos.docker; in
{
  options.cos.docker = {
    enable = lib.mkEnableOption "Enable Docker";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;

    users.users.${config.cos.username}.extraGroups = [
      "docker"
    ];
  };
}
