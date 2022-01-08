# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let

  # Set battery saving (limit charge to 60%)
  battery_conservation_mode = pkgs.writeShellScriptBin "battery-conservation" ''
    #!/usr/bin/env bash

    method='\_SB.PCI0.LPCB.EC0.VPC0.SBMC'

    on() {
        sudo modprobe acpi_call
        echo $method 3 | sudo tee /proc/acpi/call
        sudo rmmod acpi_call
    }

    off() {
        sudo modprobe acpi_call
        echo $method 5 | sudo tee /proc/acpi/call
        sudo rmmod acpi_call
    }

    $1
  '';

  iommu = true;

in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.kernel.sysctl = {
    "vm.swappiness" = lib.mkDefault 1;
    "abi.vsyscall32" = 0; # lol anti-cheat
  };

  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  boot.kernelParams = [
    "quiet"
    "rw"
    "nowatchdog"
    "hid_apple.fnmode=2"
  ] ++ lib.optionals iommu [
    "intel_iommu=on"
    "iommu=pt"
  ];

  boot.blacklistedKernelModules = [ "i2c_nvidia_gpu" ];

  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  services.fstrim.enable = true;
  services.irqbalance.enable = true;

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 2;
  };

  services.ananicy = {
    enable = true;
    # package = pkgs.ananicy-cpp;
  };
  services.acpid.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
  
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.enable = true;
  hardware.pulseaudio.support32Bit = true;
  
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
  ];

  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ vaapiIntel ];

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
    configurationLimit = 50;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

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

  security.pam.services.lightdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  security.pam.services.lightdm.gnupg.enable = true;
  security.pam.services.lightdm.gnupg.noAutostart = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    displayManager.lightdm.enable = true;
    displayManager.autoLogin.enable = false;
    displayManager.autoLogin.user = "leix";

    displayManager.defaultSession = "xsession";
    displayManager.session = [{
      manage = "desktop";
      name = "xsession";
      start = "exec $HOME/.xsession";
    }];

    displayManager.lightdm.greeters.mini = {
        enable = true;
        user = "leix";
        extraConfig = ''
            [greeter]
            show-password-label = false
            password-alignment = center
            [greeter-theme]
            background-image = "${../../users/leix/wallpapers/forest.jpg}"
            font = "Fira Mono"
            text-color = "#DDDDFF"
            error-color = "#EA6F81"
            background-color = "#1A1A1A"
            window-color = "#313131"
            border-color = "#313131"
            password-color = "#82aaff"
            password-background-color = "#1d3b53"
            password-border-color = "#1d3b53"
            sys-info-color = "#82aaff"
        '';
    };

    # Configure keymap in X11
    layout = "us";
    xkbVariant = "altgr-intl";
    xkbOptions = "lv3:caps_switch,shift:both_capslock,ralt:compose";

    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
    };

    videoDrivers = [ "nvidia" ];
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
  programs.steam.enable = true;

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
  services.dbus.packages = with pkgs; [ gcr ];

  nixpkgs.config.allowUnfree = true;

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
