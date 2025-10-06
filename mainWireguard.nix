{config, lib, pkgs, ...}:
let
  cfg = config.cos.mainWireguard;
in
{
  options.cos.mainWireguard = {
    enable = lib.mkEnableOption "enable";
    interface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
    };
    ip = lib.mkOption {
      type = lib.types.str;
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 51820;
    };
    privateKeyFile = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.interfaces.${cfg.interface}.allowedUDPPorts = [
      cfg.port
    ];

    environment.systemPackages = with pkgs; [
      wireguard-tools
    ];

    networking.wireguard = {
      enable = true;
      interfaces = {
        ${cfg.interface} = {
          ips = [ "${cfg.ip}/24" ];
          listenPort = 51820;

          privateKeyFile = cfg.privateKeyFile;

          peers = [
            {
              publicKey = "raOzdkhoag+sN2/KXz18F9ncmeTWhdmPJxQJkqsJ7FI=";
              allowedIPs = [ "10.100.0.0/24" ];
              endpoint = "50.116.49.95:51820";
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };
  };
}
