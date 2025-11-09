{ inputs, pkgs, options, config, lib, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ../cos.nix
    ];

  cos.username = "clhickey";
  cos.hostName = "clhickey-nixos";

  cos.winboat.enable = true;
  cos.docker.enable = true;

  cos.remoteBuild.enable = true;

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

  services.logind.settings.Login = {
    HandlePowerKey="suspend";
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
  };

  networking = {
    hostName = config.cos.hostName;
    networkmanager.enable = true;
  };

  cos.wireguard = {
    enable = true;
    privateKeyFile = "/home/${config.cos.username}/wireguard-keys/private";
  };

  cos.hyprland = {
    enable = true;
    wallpaper = builtins.toString ../TranscodedWallpaper.jpeg;
  };

  # auto-mount USB drives
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  hardware.bluetooth.enable = true;

  # For languini
  networking.firewall.interfaces.${config.cos.wireguard.interface}.allowedTCPPorts = [
    8000
    8080
  ];

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        AllowUsers = null;
      };
      listenAddresses = [
        {
          port = 22;
          addr = config.cos.wireguard.clientInternalIP;
        }
      ];
    };
  };

  virtualisation = {
    waydroid = {
      enable = false;
    };
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
      };
    };
    virtualbox.host = {
      enable = true;
      enableKvm = true;
      addNetworkInterface = false;
      enableExtensionPack = true;
    };
    spiceUSBRedirection.enable = true;
  };

  users.users.${config.cos.username} = {
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

  nix.settings.trusted-users = [
    "root"
    "@wheel"
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
      anki-bin
      gimp3
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
      inputs.cnvim.packages.x86_64-linux.default
      osu-lazer-bin
      thunderbird-bin
      itch
      element-desktop
      gh
      code-cursor
      firefox
      popsicle
      nixfmt-rfc-style
      graphviz
      alacritty
      prismlauncher
      google-chrome
      trilium-next-desktop
      joplin-desktop
      sshfs
      unityhub
      man-pages
      man-pages-posix
      vulkan-tools
      wireshark
      dotnetCorePackages.sdk_9_0_1xx-bin # for unit dev
      vscode-fhs
      discord
      aseprite
      pixelorama
      dig
      ncdu
    ];
    sessionVariables = {
      EDITOR = "${inputs.cnvim.packages.x86_64-linux.default}/bin/nvim";
    };
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      font-awesome
      libre-baskerville
      corefonts
      vista-fonts
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
  };

  documentation.dev.enable = true;

  home-manager.users.${config.cos.username} = { pkgs, ... }: {
    home.stateVersion = "24.11";
  };

  system.stateVersion = "24.11";
}
