rec {
  palette = {
    name = "Catppuccin Macchiato";
    teal = "#8BD5CA";
    flamingo = "#F0C6C6";
    mauve = "#C6A0F6";
    pink = "#F5BDE6";
    red = "#ED8796";
    peach = "#F5A97F";
    green = "#A6DA95";
    yellow = "#EED49F";
    blue = "#8AADF4";
    white = "#CAD3F5";
    gray = "#6E738D";
    black = "#24283A";
  };

  font_family = "JetBrainsMono Nerd Font Mono";
  font_size = "13.0";

  foreground              = palette.white;
  background              = palette.black;
  selection_foreground  = palette.black;
  selection_background  = "#F4DBD6";
# Cursor colors";
  cursor                  = "#F4DBD6";
  cursor_text_color       = "#24273A";
# URL underline color when hovering with mouse";
  url_color               = "#F4DBD6";
# Kitty window border colors";
  active_border_color     = "#B7BDF8";
  inactive_border_color   = palette.gray;
  bell_border_color       = palette.yellow;

# Tab bar colors";
  active_tab_foreground   = "#181926";
  active_tab_background   = palette.mauve;
  inactive_tab_foreground = "#CAD3F5";
  inactive_tab_background = "#1E2030";
  tab_bar_background      = "#181926";
# Colors for marks (marked text in the terminal)";
  mark1_foreground = palette.black;
  mark1_background = "#B7BDF8";
  mark2_foreground = palette.black;
  mark2_background = palette.mauve;
  mark3_foreground = palette.black;
  mark3_background = "#7DC4E4";

# The 16 terminal colors";
# black";
  color0 = "#494D64";
  color8 = "#5B6078";
# red";
  color1 = palette.red;
  color9 = palette.red;
# green";
  color2  = palette.green;
  color10 = palette.green;
# yellow";
  color3  = palette.yellow;
  color11 = palette.yellow;
# blue";
  color4  = palette.blue;
  color12 = palette.blue;
# magenta";
  color5  = palette.pink;
  color13 = palette.pink;
# cyan";
  color6  = palette.teal;
  color14 = palette.teal;
# white";
  color7  = "#B8C0E0";
  color15 = "#A5ADCB";
}
