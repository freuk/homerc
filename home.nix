{ config, pkgs, ... }:
let context = import ./context.nix { };
in {
  home.stateVersion = "20.09";
  home.username = "fre";
  home.homeDirectory = "/home/fre";

  nixpkgs = {
    overlays = [
      (final: previous: {
        tomb = previous.tomb.overrideAttrs (o: {
          src = builtins.fetchTarball
            "https://github.com/dyne/Tomb/archive/v2.8.1.tar.gz";
        });
      })
    ];
  };

  home = {
    packages = with pkgs; [
      kakoune
      tomb
      pinentry-curses
      kak-lsp
      nnn
      tig
      fasd
      ripgrep
      exa
      tmate
      gromit-mpx
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
      nixfmt
      hwloc
      htop
      git
      tree
      jq
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

  programs = {
    home-manager.enable = true;
    bash = {
      enable = true;
      shellAliases = {
        s = "nix-shell";
        t = "tig status";
        tm = "tmux";
        tb = "nc termbin.com 9999";
        ls = "exa";
        cat = "bat";
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
      bashrcExtra = (builtins.readFile ./bashrc.sh) + ''
        . ~/.nix-profile/etc/profile.d/hm-session-vars.sh
      '';
    };

    tmux = {
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
  };

  home.file = { ".inputrc".source = ./inputrc; };

  xdg.configFile = {
    "kak/kakrc".source = ./kak/kakrc;
    "kak/autoload".source = ./kak/autoload;
    "kak/colors".source = ./kak/colors;
    "kak-lsp/kak-lsp.toml".source = ./kak-lsp.toml;
    "tig/config".source = ./tig.cfg;
  };

}
