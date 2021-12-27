# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

# Set battery saving (limit charge to 60%)
let battery_conservation_mode = pkgs.writeShellScriptBin "battery-conservation" ''
  #!/usr/bin/env bash

  method='\_SB.PCI0.LPCB.EC0.VPC0.SBMC'

  on() {
      echo $method 3 | sudo tee /proc/acpi/call
  }

  off() {
      echo $method 5 | sudo tee /proc/acpi/call
  }

  $1
'';

in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.kernel.sysctl = {
    "vm.swappiness" = lib.mkDefault 1;
    "net.ipv4.ip_forward" = 1;
    "abi.vsyscall32" = 0; # lol anticheat
  };

  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  boot.kernelParams = [
    "quiet"
    "rw"
    "mitigations=off"
    "nowatchdog"
    "intel_iommu=on"
    "iommu=pt"
    "hid_apple.fnmode=2"
  ];

  boot.plymouth.enable = true;

  boot.blacklistedKernelModules = [ "i2c_nvidia_gpu" ];

  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  services.fstrim.enable = lib.mkDefault true;

  services.ananicy = {
    enable = true;
    # package = pkgs.ananicy-cpp;
  };
  services.acpid.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
  
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.enable = true;
  hardware.pulseaudio.support32Bit = true;
  
  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
    intel-media-driver
  ];


  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
    configurationLimit = 50;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";


  networking.hostName = "nixos"; # Define your hostname.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp7s0.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    displayManager.gdm.nvidiaWayland = false;
    displayManager.defaultSession = "none+awesome";

    windowManager.awesome = {
      enable = true;
      package = (pkgs.awesome.overrideAttrs (oldAttrs: rec {

        src = pkgs.fetchFromGitHub {
          owner = "awesomewm";
          repo = "awesome";
          rev = "7451c6952e0a24bd54edc0f7ecff6ad46ef65dcb";
          sha256 = "17w7n3s34482hzs9692f9wwwcl96drhg860mmj2ngzlxp3p5lv76";
        };

      })).override {
        lua = pkgs.lua5_3;
        gtk3Support = true;
        gtk3 = pkgs.gtk3;
      };
    };

    # desktopManager.gnome.enable = true;
    
    # Configure keymap in X11
    layout = "us";
    xkbVariant = "altgr-intl";
    xkbOptions = "lv3:caps_switch,shift:both_capslock,ralt:compose";

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    videoDrivers = lib.mkDefault [ "nvidia" ];
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  hardware.nvidia.modesetting.enable = true;

  services.xserver.screenSection = ''
    Option         "metamodes" "HDMI-0: nvidia-auto-select +1920+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, DP-2: nvidia-auto-select +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
    Option         "AllowIndirectGLXProtocol" "off"
    Option         "TripleBuffer" "on"
  '';

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];

  sound.enable = false;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  
    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };


  programs.gamemode.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.fish.enable = true;
  users.users.leix = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd"]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlnrdcH2stIVA1hkkOIFvebIjDALugIrTxGi6mvZQBp JuiceSSH"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEe14az/yN5C7EggpqaahIyk3PX2uFT18gaZG4LxxiGl aleix.bone@a5s102pc53"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOO1MTb4NP9qgI8P/8feqFXReeLCiB79R6YLPlXQaRQ leix@nixos"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    firefox
    openssl
    virt-manager
    battery_conservation_mode
    gnomeExtensions.appindicator
    vulkan-tools
  ];

  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon logitech-udev-rules headsetcontrol ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.gnome.excludePackages = with pkgs; [
    gnome.cheese
    gnome-photos
    gnome-connections
    gnome.gnome-software
    gnome.yelp
    gnome.gnome-music
    gnome.gnome-terminal
    gnome.gedit
    epiphany
    gnome.totem
    gnome.tali
    gnome.iagno
    gnome.hitori
    gnome.atomix
    gnome-tour
  ];
  programs.geary.enable = false;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    passwordAuthentication = false;
    permitRootLogin = "no";
    enable = true;
    ports = [ 22 2322 ];
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
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "DejaVu Serif" ];
        sansSerif = [ "DejaVu Sans" ];
        monospace = [ "Fira Mono" ];
      };
    };
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    autoOptimiseStore = true;
    trustedUsers = [ "root" "leix" ];
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
