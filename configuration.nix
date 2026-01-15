# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options   and in the NixOS manual (`nixos-help`).

{ config, pkgs, inputs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.11";

  # File Systems с добавленными субволами (@nix, @log, @cache)
  # ЗАМЕНИ UUID на реальные из blkid
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/твой-uuid";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/твой-uuid";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/твой-uuid";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd" "noatime" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/твой-uuid";
    fsType = "btrfs";
    options = [ "subvol=@log" "compress=zstd" "noatime" ];
  };

  fileSystems."/var/cache" = {
    device = "/dev/disk/by-uuid/твой-uuid";
    fsType = "btrfs";
    options = [ "subvol=@cache" "compress=zstd" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/твой-uuid";
    fsType = "vfat";
  };

  # Btrfs autoScrub
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" "/home" "/nix" "/var/log" "/var/cache" ];
  };

  # Boot
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
      editor = false;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  boot.kernelParams = [ "quiet" "splash" ];
  boot.supportedFilesystems = [ "btrfs" ];

  # ZRAM (подняли до 75%)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 75;
  };

  # Networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    
    # Firewall configuration
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ ];
    };
  };

  # OpenSSH сервер
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PubkeyAuthentication = true;
      PermitRootLogin = "no";
      PermitEmptyPasswords = false;
      X11Forwarding = true;
      PrintMotd = true;
    };
  };

  # MOTD
  environment.etc."motd".text = ''
    Welcome to ${config.networking.hostName}!
    NixOS ${config.system.nixos.release}
  '';

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  # Audio - PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Localization
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";
  
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # User Configuration
  users.users.denis = {
    isNormalUser = true;
    description = "Main User";
    extraGroups = [ 
      "wheel" 
      "networkmanager" 
      "audio" 
      "video" 
      "storage"
      "input"
    ];
    shell = pkgs.bash;
    createHome = true;
    home = "/home/denis";
  };

  # Sudo Configuration
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };

  # Programs - SSH агент
  programs.ssh = {
    startAgent = true;
    agentTimeout = "30m";
  };

  # Podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # System Packages (только системные утилиты)
  environment.systemPackages = with pkgs; [
    # Основные утилиты
    vim
    wget
    curl
    git
    htop
    btop
    nano
    networkmanagerapplet
    bluez
    bluez-tools
    btrfs-progs
    mc
    fastfetch
    
    # SSH
    openssh
    
    # Сетевые утилиты
    nmap
    netcat-openbsd
    
    # Системные утилиты
    usbutils
    pciutils
    
    # Подсветка и шрифты
    bat
    ripgrep

    # Podman-related
    podman-compose
    dive

    # Для отладки
    psmisc # содержит pstree, killall и другие
    lsof
    file
    tree

    # xorg утилиты - теперь будут в home.nix
    # xorg.xinit # для запуска startx
    # xorg.xrandr
    # xorg.xset
    # xclip
  ];
  
  # Дополнительные сервисы
  services = {
    dbus.enable = true;
    blueman.enable = true;
    udisks2.enable = true;
  };
  
  # Включение firmware
  hardware.enableRedistributableFirmware = true;

  # Nix settings для flakes
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "denis" ];
    };
  
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # Логи journald
  services.journald.extraConfig = "SystemMaxUse=300M";
}
