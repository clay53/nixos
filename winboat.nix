{inputs, config, pkgs, lib, ...}:
let
  cfg = config.cos.winboat;
in
{
  options.cos.winboat = {
    enable = lib.mkEnableOption "Enable winboat";
  };

  config = lib.mkIf cfg.enable {
    cos.docker.enable = true;

    environment.systemPackages = [
      pkgs.winboat
      pkgs.freerdp
    ];
  };
}
