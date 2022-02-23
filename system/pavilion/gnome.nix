{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.displayManager.gdm.settings = {
    "greeting" = { "include" = "leix"; };
  };
  services.xserver.desktopManager.gnome.enable = true;

  # gnome app indicator
  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];

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
}
