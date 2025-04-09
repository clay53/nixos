{ inputs, pkgs, options, ... }:
let
  hostName = "clhickey-nixos";
  username = "clhickey";
in
{
  imports =
    [
      ./hardware-configuration.nix
      "${inputs.home-manager}/nixos"
    ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [
      "ntfs"
    ];
    binfmt = {
      emulatedSystems = [
        "aarch64-linux"
      ];
    };
  };

  networking = {
    inherit hostName;
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
    inputMethod = {
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
  };

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    displayManager.sddm.enable = true;
    printing.enable = true;
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };

  hardware = {
    bluetooth.enable = true;
    opentabletdriver.enable = true;
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  users.users.${username} = {
    isNormalUser = true;
    description = "Clayton Lopez Hickey";
    extraGroups = [
      "networkmanager"
      "wheel"
      "adbusers"
      "libvirtd"
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment = {
    systemPackages = with pkgs; [
      fastfetch
      wget
      brave
      kdePackages.kate
      nextcloud-client
      obs-studio
      vlc
      kdePackages.kdenlive
      tmux
      htop
      helvum
      libreoffice-fresh
      obsidian
      anki-bin
      gimp
      audacity
      ffmpeg
      zoom-us
      inkscape
      freecad
      kdePackages.filelight
      prismlauncher
      blender
      sqlitebrowser
      arduino-ide
      josm
      krita
      jetbrains.idea-ultimate
      android-studio
      gparted
      jdk
      jdk8
      slack
      inputs.penn-nix.packages.x86_64-linux.waypoint-client
      #vscode-fhs
      inputs.cnvim.packages.x86_64-linux.default
      osu-lazer-bin
      wl-clipboard
      thunderbird-bin
      itch
      element-desktop
      gh
      vscode-fhs
      firefox
      popsicle
      kdePackages.kget
      nixfmt-rfc-style
      graphviz
      wdisplays
      pwvucontrol
      alacritty
      pcmanfm
      kdePackages.okular
    ];
    sessionVariables = {
      EDITOR = "${inputs.cnvim.packages.x86_64-linux.default}/bin/nvim";
    };
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      font-awesome
      libre-baskerville
      corefonts
      vistafonts
    ];
  };

  programs = {
    adb.enable = true;
    steam = {
      enable = true;
    };
    java = {
      enable = true;
      package = pkgs.jdk;
    };
    nix-ld = {
      enable = true;
      libraries = options.programs.nix-ld.libraries.default ++ [
        pkgs.xorg.libXext
        pkgs.xorg.libX11
        pkgs.xorg.libXrender
        pkgs.xorg.libXtst
        pkgs.xorg.libXi
        pkgs.freetype
      ];
    };
    virt-manager.enable = true;
    ladybird = {
        enable = true;
    };
    git = {
        enable = true;
    };
    gnupg.agent = {
        enable = true;
    };
    hyprland = {
      enable = true;
    };
  };

  home-manager.users.${username} = { pkgs, ... }: {
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
        ];
        "$terminal" = "${pkgs.alacritty}/bin/alacritty";
        "exec-once" = [
          "${pkgs.waybar}/bin/waybar"
          "${pkgs.fcitx5}/bin/fcitx5 -r -s 5"
          "${pkgs.hypridle}/bin/hypridle"
        ];
        "$mod" = "SUPER";
        bind = [
          "$mod, RETURN, exec, $terminal"
          "$mod, Q, killactive"
          "$mod&SHIFT, Q, forcekillactive"
          "$mod, E, exec, ${pkgs.wofi}/bin/wofi --show run"
          "$mod, F, fullscreen, 0"
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
        };
        #xwayland = {
        #  force_zero_scaling = true;
        #};
      };
    };

    services.hyprpolkitagent.enable = true;

    services.hypridle = {
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
	        "temperature"
	        "backlight"
	        "keyboard-state"
	        "sway/language"
	        "battery"
	        "clock"
	        "tray"
	      ];
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
	      network = {
	        "format-wifi" = "{essid} ({signalStrength}%)";
            "format-ethernet" = "{ipaddr}/{cidr}";
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
	        format = "{capacity}% {icon}";
              "format-charging" = "{capacity}% ";
              "format-plugged" = "{capacity}% ";
              "format-alt" = "{time} {icon}";
	        "format-icons" = [
	          ""
              ""
              ""
              ""
              ""
	        ];
	      };
	      clock = {
	        "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
	        "format-alt" = "{:%Y-%m-%d}";
	        format = "{:%H:%M:%S}";
	        interval = 1;
	      };
        };
	  };
    };

    home.stateVersion = "24.11";
  };

  system.stateVersion = "24.11";
}
