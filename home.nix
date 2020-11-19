{ config, pkgs, ... }:
let
  context = import ./context.nix { };
  x11 = context.x11;
  optionalX11Attrs = as: if (context.x11) then as else { };
  optionalX11s = ls: if (context.x11) then ls else [ ];
in {
  home.stateVersion = "20.03";

  nixpkgs = optionalX11Attrs {
    overlays = [
      (final: previous: {
        obs-v4l2sink =
          previous.lib.callPackageWith previous ./obs-v4l2sink.nix { };
      })
    ];
  };

  home = {
    packages = with pkgs;
      [
        kakoune
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
      ] ++ pkgs.lib.optionals (context.x11) [
        gnome3.gnome-tweak-tool
        protonmail-bridge
        skypeforlinux
        conky
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
    } // optionalX11Attrs { BROWSER = "firefox"; };
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
  } // optionalX11Attrs {
    obs-studio = {
      enable = true;
      plugins = [ pkgs.obs-v4l2sink ];
    };
  };

  home.file = {
    ".inputrc".source = ./inputrc;
  } // optionalX11Attrs { ".conkyrc".source = ./conkyrc; };

  xdg.configFile = {
    "kak/kakrc".source = ./kak/kakrc;
    "kak/autoload".source = ./kak/autoload;
    "kak/colors".source = ./kak/colors;
    "kak-lsp/kak-lsp.toml".source = ./kak-lsp.toml;
    "tig/config".source = ./tig.cfg;
  } // optionalX11Attrs { "gromit-mpx.cfg".source = ./gromit-mpx.cfg; };

}
