{inputs, config, pkgs, lib, ...}:
let
  cfg = config.cos.winboat;
in
{
  options.cos.winboat = {
    enable = lib.mkEnableOption "Enable winboat";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;

    users.users.${config.cos.username}.extraGroups = [
      "docker"
    ];

    environment.systemPackages = [
      inputs.winboat.packages.x86_64-linux.winboat
      pkgs.freerdp
    ];
  };
}
