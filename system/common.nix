# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  update_system = pkgs.writeShellScriptBin "update-system" ''
    cd ~/.dotfiles
    set -e
    nixos-rebuild build --flake .# && ${pkgs.nvd}/bin/nvd diff /run/current-system result
    read -r -p "Switch? [Y/n]" response
    response=''${response,,} # tolower
    if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
      sudo nixos-rebuild switch --flake .#
    fi
  '';
in {
  boot.kernel.sysctl = {
    "vm.swappiness" = lib.mkDefault 1;
    "vm.vfs_cache_pressure" = lib.mkDefault 50;
  };

  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";

  boot.kernelParams = [
    "quiet"
    "rw"
    "nowatchdog"
    "hid_apple.fnmode=2"
    "mitigations=off"
  ];

  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  documentation.enable = true;
  documentation.man.enable = true;
  documentation.dev.enable = true;

  services.fstrim.enable = true;
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.interval = "monthly";

  services.avahi.enable = true;
  services.irqbalance.enable = true;

  services.fwupd.enable = true;

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 2;
    enableNotifications = true;
  };

  services.ananicy = {
    enable = true;

    package = pkgs.ananicy-cpp;

    extraRules = ''
      { "name" : ".Discord-wrapped", "type" : "Chat" }
    '';
  };
  services.acpid.enable = true;

  services.xserver.wacom.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.enable = true;
  hardware.pulseaudio.support32Bit = false;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  };

  hardware.opengl.extraPackages = with pkgs;
    lib.mkForce [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      # nvidia-vaapi-driver
    ];

  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [vaapiIntel];

  programs.dconf.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
    configurationLimit = 50;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  networking.wireless.enable = false; # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";

    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
      "ca_ES.UTF-8/UTF-8"
      "es_ES.UTF-8/UTF-8"
    ];

    extraLocaleSettings = {
      LC_TIME = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  services.gnome.gnome-keyring.enable = true;

  programs.mtr.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  systemd.enableUnifiedCgroupHierarchy = true;

  systemd.targets = {
    sleep.enable = true;
    suspend.enable = true;
    hibernate.enable = true;
    hybrid-sleep.enable = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [pkgs.brlaser];

  sound.enable = true;
  hardware.pulseaudio.enable = lib.mkForce false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = false;

    pulse.enable = true;

    media-session.enable = false;
    wireplumber.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.fish.enable = true;
  users.users.leix = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "libvirtd" "audio" "video"]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP01irZGcIE6n5svXRpAqFNgdRl15cum7vEV1go9qvI5 JuiceSSH"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHPm9yDy7gOVOAsIPqp6q0XC06RSnZJUh959HJdFkCdZ aleix.bone@c6s302pc63"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOO1MTb4NP9qgI8P/8feqFXReeLCiB79R6YLPlXQaRQ leix@nixos-pav"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPWmQFG8ogdMgYH0Ldi4gJK/PWBQBfnTXMwtqq4cHBCp leix@nixos"
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    openssl
    update_system
  ];

  system.activationScripts.diff = ''
    [ -d /run/current-system ] && ${pkgs.nixUnstable}/bin/nix store \
        --experimental-features 'nix-command' \
        diff-closures /run/current-system "$systemConfig"
  '';

  services.systembus-notify.enable = true;

  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon logitech-udev-rules headsetcontrol];
  services.dbus.packages = with pkgs; [gcr gnome.gnome-keyring];

  services.restic.backups = {
    localbackup = {
      initialize = true;
      user = "leix";
      passwordFile = "/etc/nixos/secrets/restic-password";
      paths = [
        "/home/leix"
      ];
      repository = "/mnt/data/backups/restic";
      timerConfig = {
        OnCalendar = "weekly";
      };
    };
  };

  # Mout MTP and other network shares
  services.gvfs.enable = true;

  nixpkgs.config.allowUnfree = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    passwordAuthentication = false;
    permitRootLogin = "yes";
    enable = true;
    ports = [22 2322];
    forwardX11 = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      dejavu_fonts
      fira
      fira-code
      fira-code-symbols
      fira-mono
      liberation_ttf
      libre-baskerville
      libre-bodoni
      libre-caslon
      libre-franklin
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      (nerdfonts.override {fonts = ["FiraCode" "DroidSansMono" "JetBrainsMono"];})
    ];
    fontconfig = {
      defaultFonts = {
        serif = ["DejaVu Serif"];
        sansSerif = ["DejaVu Sans"];
        monospace = ["Fira Mono"];
      };
    };
  };

  powerManagement.cpuFreqGovernor = "performance";

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';

    settings = {
      trusted-users = ["root" "leix"];
      auto-optimise-store = true;

      substituters = [
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc.automatic = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
  system.autoUpgrade.enable = true;
}
