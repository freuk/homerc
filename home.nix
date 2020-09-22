{ config, pkgs, ... }: {
  programs.home-manager.enable = true;
  home.stateVersion = "20.03";

  xdg.configFile."kak/kakrc".source = ./kak/kakrc;
  xdg.configFile."kak/autoload".source = ./kak/autoload;
  xdg.configFile."kak/colors".source = ./kak/colors;

  home = {

    packages = [
      pkgs.kakoune
      pkgs.nnn
      (pkgs.writeShellScriptBin "t" "${pkgs.tig}/bin/tig status $@").out
    ];

    sessionVariables = { NNN_OPENER = nnn/nuke; };
  };
  home.file."tig/tig.cfg".source = ./tig.cfg;
}
