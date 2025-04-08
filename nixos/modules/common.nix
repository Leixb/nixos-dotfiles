# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, lib, inputs, ... }:
let
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
in
{
  boot.kernel.sysctl = {
    "vm.swappiness" = lib.mkDefault 1;
    "vm.vfs_cache_pressure" = lib.mkDefault 50;
  };

  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";

  boot.kernelParams =
    [ "quiet" "rw" "nowatchdog" "hid_apple.fnmode=2" "mitigations=off" ];

  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  documentation.enable = true;
  documentation.man.enable = true;
  documentation.dev.enable = true;

  services.avahi.enable = true;
  services.irqbalance.enable = true;

  services.fwupd.enable = true;

  systemd.oomd = {
    enable = true;
    # Fedora enables the first and third option by default. See the 10-oomd-* files here:
    # https://src.fedoraproject.org/rpms/systemd/tree/806c95e1c70af18f81d499b24cd7acfa4c36ffd6
    enableRootSlice = true;
    enableSystemSlice = false;
    enableUserSlices = true;
  };

  services.ananicy = {
    enable = true;

    package = pkgs.ananicy-cpp;
    # settings.loglevel = "info";
    extraRules = [
      { name = "League of Legends.exe"; type = "game"; }
    ];
  };
  services.acpid.enable = true;

  services.xserver.wacom.enable = true;

  services.gnome.gnome-keyring.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  hardware.enableRedistributableFirmware = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  # hardware.opengl.extraPackages = with pkgs;
  #   [
  #     intel-media-driver
  #     vaapiIntel
  #     vaapiVdpau
  #     libvdpau-va-gl
  #   ];

  # TODO: put this in kuro and all other
  # hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ vaapiIntel ];

  programs.dconf.enable = true;
  programs.light.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    # enable = true;
    editor = false;
    configurationLimit = 50;
  };
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  networking.wireless.enable =
    false; # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  # networking.networkmanager.wifi.backend = "iwd";

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

  programs.mtr.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  systemd.targets = {
    sleep.enable = true;
    suspend.enable = true;
    hibernate.enable = true;
    hybrid-sleep.enable = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];
  services.printing.browsed.enable = lib.mkForce false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = lib.mkDefault false;

    pulse.enable = true;

    wireplumber.enable = true;
  };

  security.pam.services.swaylock = { };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.fish.enable = true;
  users.users.leix = {
    description = "Aleix";
    uid = 1000;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "audio"
      "video"
      "input"
    ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP01irZGcIE6n5svXRpAqFNgdRl15cum7vEV1go9qvI5 JuiceSSH"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPWmQFG8ogdMgYH0Ldi4gJK/PWBQBfnTXMwtqq4cHBCp leix@kuro"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMz6YAvxivW35ndT4rH8jBBTHYSaCW/mn2y7+pOnIuq+ leix@nixos-pav"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILbUye0Ne66GM3CYtEAvAqOKd5+fyuxCVaq5ebtCgT62 leix@asus"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIIFiqXqt88VuUfyANkZyLJNiuroIITaGlOOTMhVDKjf abonerib@bsc-84885016"
    ];
  };

  security.pam.services.leix.enableGnomeKeyring = true;

  environment.systemPackages = with pkgs; [
    cntr
    vim
    wget
    openssl
    update_system
    man-pages
    man-pages-posix
  ];

  system.activationScripts.diff = ''
    [ -d /run/current-system ] && ${pkgs.nix}/bin/nix store \
        --experimental-features 'nix-command' \
        diff-closures /run/current-system "$systemConfig"
  '';

  services.systembus-notify.enable = true;

  services.udev.packages = with pkgs; [
    gnome-settings-daemon
    logitech-udev-rules
    headsetcontrol
  ];
  services.dbus.packages = with pkgs; [ gcr at-spi2-core ];

  # Mout MTP and other network shares
  services.gvfs.enable = true;

  nixpkgs.config.allowUnfree = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    settings = {
      # PermitRootLogin = "yes";
      PasswordAuthentication = false;
      X11Forwarding = true;
    };
    enable = true;
    ports = [ 22 2322 ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
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
      noto-fonts-cjk-sans
      noto-fonts-emoji
      montserrat
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
      nerd-fonts.jetbrains-mono
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "DejaVu Serif" ];
        sansSerif = [ "DejaVu Sans" ];
        monospace = [ "Fira Mono" ];
      };
    };
  };

  xdg.portal.enable = true;

  # Put xserver log files in a proper location
  services.xserver.logFile = "/var/log/Xorg.0.log";

  security.polkit.enable = true;

  powerManagement.cpuFreqGovernor = "performance";

  nix = {
    # package = pkgs.nixVersions.unstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';

    settings = {
      trusted-users = [ "root" "leix" ];
      auto-optimise-store = true;

      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
        "https://devenv.cachix.org"
        "https://hyprland.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
    gc.automatic = true;
  };

  system.autoUpgrade.enable = true;

  boot.supportedFilesystems = [ "ntfs" ];
}
