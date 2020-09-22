{ config, pkgs, ... }:
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  #xdg.enable =true;
  xdg.configFile."kak/kakrc".source = ./kak/kakrc;
  xdg.configFile."kak/autoload".source = ./kak/autoload;
  xdg.configFile."kak/colors".source = ./kak/colors;
  home.packages = [pkgs.kakoune];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.03";
}
