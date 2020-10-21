{ config, pkgs, ... }: {
  programs.home-manager.enable = true;
  home.stateVersion = "20.03";

  nixpkgs.overlays = [
    (final: previous: {
      obs-v4l2sink = previous.lib.callPackageWith previous ./obs-v4l2sink.nix {};
    })
  ];


  home = {
    packages = with pkgs; [
      kakoune
      kak-lsp
      nnn
      tig
      fasd
      ripgrep
      exa
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
      nixfmt
      hwloc
      htop
      git
      tree
      bat
      fzf
    ];

    sessionVariables = {
      TERM = "tmux-256color";
      EDITOR = "kak";
      VISUAL = "kak";
      PAGER = "less";
      NNN_OPENER = ./nnn/nuke;
      NNN_PLUG = "f:preview-tui";
      NNN_FIFO = "/tmp/nnn.fifo";
      LANG = "C.UTF-8";
    };
  };

  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-v4l2sink ];
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
      g = "git";
      ga = "git add";
      gps = "git push";
      k = "kak";
      gpu = "git pull";
    };
    bashrcExtra = (builtins.readFile ./bashrc) + ''
      . ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    '';
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
  xdg.configFile."kak-lsp/kak-lsp.toml".source = ./kak-lsp.toml;

  xdg.configFile."tig/config".source = ./tig.cfg;

}
