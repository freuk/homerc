{ config, pkgs, ... }: {
  programs.home-manager.enable = true;
  home.stateVersion = "20.03";

  home = {
    packages = with pkgs; [
      kakoune
      nnn
      tig
      fasd
      ripgrep
      exa
      nixfmt
      hwloc
      htop
      git
      tree
      bat
    ];

    sessionVariables = {
      TERM = "tmux-256color";
      NNN_OPENER = ./nnn/nuke;
      NNN_PLUG = "f:preview-tui";
      NNN_FIFO = "/tmp/nnn.fifo";
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      s = "nix-shell";
      t = "tig status";
      tm = "tmux";
      tb = "nc termbin.com 9999";
      ls = "exa";
      ll = "exa -l";
      l = "exa -la";
      gst = "git status";
      gc = "git commit";
      ga = "git add";
      gps = "git push";
      k = "kak";
      gpu = "git pull";
    };
    bashrcExtra = builtins.readFile ./bashrc;
  };

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      pain-control
      copycat
      fzf-tmux-url
      open
      prefix-highlight
    ];
    extraConfig = builtins.readFile ./tmux.cfg;
  };

  home.file.".inputrc".source = ./inputrc;

  xdg.configFile."kak/kakrc".source = ./kak/kakrc;
  xdg.configFile."kak/autoload".source = ./kak/autoload;
  xdg.configFile."kak/colors".source = ./kak/colors;

  xdg.configFile."tig/config".source = ./tig.cfg;

}
