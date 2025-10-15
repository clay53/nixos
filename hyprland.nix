{config, pkgs, lib, ...}:
let cfg = config.cos.hyprland; in
{
  options.cos.hyprland = {
    enable = lib.mkEnableOption "preconfigured Hyprland";
    wallpaper = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;

    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.printing.enable = true;
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    services.blueman.enable = lib.mkIf config.hardware.bluetooth.enable true;

    hardware.opentabletdriver.enable = true;

    security = {
      rtkit.enable = true;
      polkit.enable = true;
    };

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
	    addons = with pkgs; [
          fcitx5-gtk
          fcitx5-configtool
          fcitx5-mozc
        ];
      };
    };

    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
      kdePackages.kget
      wdisplays
      pwvucontrol
      pcmanfm
      kdePackages.okular
      kdePackages.ark
      kdePackages.gwenview
      yaru-theme
    ];

    services.hypridle.enable = true;

    home-manager.users.${config.cos.username} = {pkgs, ...}: {
      wayland.windowManager.hyprland = {
        enable = true;
        plugins = [
          #pkgs.hyprlandPlugins.hy3
        ];
        settings = {
          env = [
            # Base on https://wiki.hyprland.org/Configuring/Environment-variables/
            "GDK_BACKEND,wayland,x11,*"
            "QT_QPA_PLATFORM,wayland;xcb"
            "SDL_VIDEODRIVER,wayland"
            "CLUTTER_BACKEND,wayland"
            "XCURSOR_THEME,Yaru"
            "XCURSOR_SIZE,32"
            "GDK_SCALE,1.333333"
          ];
          "$terminal" = "${pkgs.alacritty}/bin/alacritty";
          "exec-once" = [
            "${pkgs.waybar}/bin/waybar"
            "fcitx5 -d"
            "hyprpaper"
            "hypridle"
            "${pkgs.hyprland}/bin/hyprctl setcursor Yaru 24"
            "${pkgs.nextcloud-client}/bin/nextcloud"
            "hyprlock"
          ];
          "$mod" = "SUPER";
          bind = [
            "$mod, RETURN, exec, $terminal"
            "$mod, Q, killactive"
            "$mod&SHIFT, Q, forcekillactive"
            "$mod, E, exec, ${pkgs.wofi}/bin/wofi --show run"
            "$mod, F, fullscreen, 3"
            "$mod&SHIFT, W, movewindow, u"
            "$mod&SHIFT, A, movewindow, l"
            "$mod&SHIFT, S, movewindow, d"
            "$mod&SHIFT, D, movewindow, r"
            "$mod, W, movefocus, u"
            "$mod, A, movefocus, l"
            "$mod, S, movefocus, d"
            "$mod, D, movefocus, r"
            "$mod, H, moveactive, -25 0"
            "$mod, J, moveactive, 0 25"
            "$mod, K, moveactive, 0 -25"
            "$mod, L, moveactive, 25 0"
            "$mod&SHIFT, H, resizeactive, -25 0"
            "$mod&SHIFT, J, resizeactive, 0 -25"
            "$mod&SHIFT, K, resizeactive, 0 25"
            "$mod&SHIFT, L, resizeactive, 25 0"
            "$mod, space, togglefloating"
            "$mod, G, togglegroup"
            "$mod&SHIFT, G, moveoutofgroup"
            "$mod&CTRL, W, moveintogroup, u"
            "$mod&CTRL, A, moveintogroup, l"
            "$mod&CTRL, S, moveintogroup, d"
            "$mod&CTRL, D, moveintogroup, r"
            "$mod, tab, changegroupactive, f"
            "$mod&SHIFT, tab, changegroupactive, b"
            "$mod&CTRL, D, movegroupwindow, f"
            "$mod&CTRL, A, movegroupwindow, b"
            ", XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"
            ", XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
            ", XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
            ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
            ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
            ", Print, exec, ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" -t png - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png"
            "$mod&SHIFT, V, exec, ${pkgs.wl-clipboard}/bin/wl-paste | ${pkgs.coreutils}/bin/tee \"$(${pkgs.zenity}/bin/zenity --file-selection --save --confirm-overwrite)\""
          ]++ (
            builtins.concatLists (
              builtins.genList (i:
                [
                  "$mod, code:1${toString i}, workspace, ${toString (i+1)}"
                  "$mod SHIFT, code:1${toString i}, movetoworkspacesilent, ${toString (i+1)}"
                ]
              )
              9
            )
          )++ [
            "$mod, code:19, workspace, 10"
            "$mod SHIFT, code:19, movetoworkspacesilent, 10"
          ];
          monitor = "eDP-1, 2256x1504, 0x0, 1.333333";
          general = {
            gaps_in = 0;
            gaps_out = 0;
          };
          input = {
            accel_profile = "flat";
            sensitivity = 1.0;
            touchpad = {
              disable_while_typing = false;
            };
          };
          xwayland = {
            force_zero_scaling = true;
          };
        };
      };

      services = {
        hyprpolkitagent.enable = true;

        hyprpaper = {
          enable = true;
          settings = {
            ipc = true;
            preload = [
              cfg.wallpaper
            ];
            wallpaper = [
              ",${cfg.wallpaper}"
            ];
          };
        };
      };

      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dms on";
          };
        };
      };

      programs.hyprlock = {
        enable = true;
      };

      programs.waybar = {
        enable = true;
        settings = {
	      mainBar = {
            height = 30;
	        spacing = 4;
	        "modules-left" = [
	          "hyprland/workspaces"
	          "sway/mode"
	          "sway/scratchpad"
	          "custom/media"
	        ];
	        "modules-center" = [
	          "sway/window"
	        ];
	        "modules-right" = [
	          "mpd"
	          "pulseaudio"
	          "network"
	          "cpu"
	          "memory"
	          "backlight"
	          "battery"
	          "clock"
	          "tray"
	        ];
            backlight = {
              format = "{percent}% {icon}";
              format-icons = [""];
              tooltip = false;
            };
	        pulseaudio = {
	          "format" = "{volume}% {icon} {format_source}";
              "format-bluetooth" = "{volume}% {icon} {format_source}";
              "format-bluetooth-muted" = " {icon} {format_source}";
              "format-muted" = " {format_source}";
              "format-source" = "{volume}% ";
              "format-source-muted" = "";
              "format-icons" = {
	            "headphone" = "";
	            "hands-free" = "";
	            "headset" = "";
	            "phone" = "";
	            "portable" = "";
	            "car" = "";
	            "default" = [
	              ""
	    	        ""
	              ""
	            ];
               };
               "on-click" = "pavucontrol";
	        };
            cpu = {
              format = "{usage}% ";
            };
            memory = {
              format = "{used}/{total} GiB";
              tooltip = false;
            };
	        network = {
	          "format-wifi" = "{essid} ({signalStrength}%) ";
              "format-ethernet" = "{ipaddr}/{cidr} 󰊗";
              "tooltip-format" = "{ifname} via {gwaddr}";
              "format-linked" = "{ifname} (No IP)";
              "format-disconnected" = "Disconnected";
              "format-alt" = "{ifname}: {ipaddr}/{cidr}";
	        };
	        battery = {
	          states = {
	            warning = 30;
	    	    critical = 15;
	          };
	          format = "{capacity}% {icon} {time}";
	          "format-icons" = [
	            ""
                ""
                ""
                ""
                ""
	          ];
              "format-charging" = "{capacity}%   {time}";
              "format-plugged" = "{capacity}%  {time}";
              tooltip = false;
	        };
	        clock = {
	          "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
	          format = "{:%Y-%m-%d %H:%M:%S}";
	          interval = 1;
	        };
          };
	    };
      };
    };
  };
}
