{config, lib, pkgs, ...}:
let
  cfg = config.cos.wireguard;
in
{
  options.cos.wireguard = {
    enable = lib.mkEnableOption "enable";
    interface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
    };
    clientPubOptionsMap = lib.mkOption {
      type = lib.types.submodule {
        options = lib.attrsets.genAttrs config.cos.knownHosts (host: lib.mkOption {
          type = lib.types.nullOr (lib.types.submodule {
            options = {
              clientNumber = lib.mkOption {
                type = lib.types.ints.u8;
                description = "appended to IP";
              };
              ip = lib.mkOption {
                type = lib.types.str;
                default = "${cfg.baseIP}.${builtins.toString cfg.clientPubOptionsMap.${host}.clientNumber}";
              };
              port = lib.mkOption {
                type = lib.types.port;
                default = 51820;
              };
              publicKey = lib.mkOption {
                type = lib.types.str;
              };
            };
          });
          default = null;
        });
      };
    };
    baseIP = lib.mkOption {
      type = lib.types.str;
      default = "10.100.0";
    };
    clientInternalIP = lib.mkOption {
      type = lib.types.str;
      default = cfg.clientPubOptionsMap.${config.cos.hostName}.ip;
    };
    clientInternalPort = lib.mkOption {
      type = lib.types.port;
      default = cfg.clientPubOptionsMap.${config.cos.hostName}.port;
    };
    clientPublicKey = lib.mkOption {
      type = lib.types.str;
      default = cfg.clientPubOptionsMap.${config.cos.hostName}.publicKey;
    };
    privateKeyFile = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.interfaces.${cfg.interface}.allowedUDPPorts = [
      cfg.clientInternalPort
    ];

    environment.systemPackages = with pkgs; [
      wireguard-tools
    ];

    environment.etc."resolv.conf".text = ''
      nameserver 10.100.0.1
      nameserver 1.1.1.1
    '';

    networking.wireguard = {
      enable = true;
      interfaces = {
        ${cfg.interface} = {
          ips = [ "${cfg.clientInternalIP}/24" ];
          listenPort = cfg.clientInternalPort;

          privateKeyFile = cfg.privateKeyFile;

          peers = [
            {
              publicKey = cfg.clientPubOptionsMap.loadedskypotato.publicKey;
              allowedIPs = [ "${cfg.baseIP}.0/24" ];
              endpoint = "${config.cos.knownPublicIPs.loadedskypotato}:${builtins.toString cfg.clientPubOptionsMap.loadedskypotato.port}";
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };
  };
}
