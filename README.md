# homerc

```
curl -L https://nixos.org/nix/install | sh
rm -r ~/.config/nixpkgs
git clone https://github.com/freuk/homerc.git ~/.config/nixpkgs
nix-channel --add https://github.com/rycee/home-manager/archive/release-20.03.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```
