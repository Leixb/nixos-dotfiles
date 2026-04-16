{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      dejavu_fonts
      fira
      fira-code
      fira-code-symbols
      fira-mono
      fixedsys-excelsior
      liberation_ttf
      libre-baskerville
      libre-bodoni
      libre-caslon
      libre-franklin
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
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

  console = {
    useXkbConfig = true;
  };
}
