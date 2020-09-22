{ config, pkgs, ... }: {
  programs.home-manager.enable = true;
  home.stateVersion = "20.03";

  xdg.configFile."kak/kakrc".source = ./kak/kakrc;
  xdg.configFile."kak/autoload".source = ./kak/autoload;
  xdg.configFile."kak/colors".source = ./kak/colors;
  xdg.configFile."tig/config".source = ./tig.cfg;

  home = {

    packages = [
      pkgs.kakoune
      pkgs.nnn
      (pkgs.writeShellScriptBin "t" "${pkgs.tig}/bin/tig status $@").out
      pkgs.tig
    ];

    sessionVariables = {
      TERM = "tmux-256color";
      NNN_OPENER = nnn/nuke;
      NNN_PLUG = "f:preview-tui";
      NNN_FIFO = "/tmp/nnn.fifo";
    };
  };

  programs.bash = {
    enable = true;
    bashrcExtra = builtins.readFile ./bashrc;
    };
  home.file.".inputrc".source = ./inputrc;
  # home.file.".bashrc".source = ./bashrc;

  # programs.bash = { enable = true; };
}
