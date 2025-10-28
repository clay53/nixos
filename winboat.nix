{inputs, config, pkgs, ...}:
{
  config = {
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
