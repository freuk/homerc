# homerc

for a non-nixos system:
```
#nix installation
curl -L https://nixos.org/nix/install | sh
. /home/cc/.nix-profile/etc/profile.d/nix.sh

#making everything 20.03
nix-channel --remove nixpkgs
nix-channel --add https://nixos.org/channels/nixos-20.03 nixpkgs
nix-channel --add https://github.com/rycee/home-manager/archive/release-20.03.tar.gz home-manager
nix-channel --update

#putting dotfiles in position
rm -rf ~/.config/nixpkgs
git clone https://github.com/freuk/homerc.git ~/.config/nixpkgs

# potentially an issue depending on the situation, evidently:
rm ~/.bash_profile
rm ~/.bashrc

export TERM=tmux-256color
nix-shell '<home-manager>' -A install
```
