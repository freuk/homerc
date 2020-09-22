# homerc

```
curl -L https://nixos.org/nix/install | sh

rm -r ~/.config/nixpkgs
git clone https://github.com/freuk/homerc.git ~/.config/nixpkgs

nix-channel --remove nixpkgs
nix-channel --add https://nixos.org/channels/nixos-20.03 nixpkgs
nix-channel --add https://github.com/rycee/home-manager/archive/release-20.03.tar.gz home-manager
nix-channel --update

export TERM=tmux-256color

# potentially an issue depending on the situation, evidently:
rm ~/.bash_profile
rm ~/.bashrc

nix-shell '<home-manager>' -A install
```
