# Symphony

![Logo](./demo.png)

Meticulously crafted collection of NixOS configurations tailored for my systems. This repository encapsulates a unified setup across different machines, ensuring a consistent and efficient environment no matter where I’m working. The configurations are designed with modularity and clarity in mind, making it easy to adapt and scale. Whether it's setting up a new machine or refining an existing setup, Symphony brings what I believe to be the best practices in NixOS configuration management, unified under a single, cohesive structure. System and home manager configurations are kept separate to keep configuration flexible and modular.

| System 	| Architecture                   	| Description                               	|
|--------	|--------------------------------	|-------------------------------------------	|
| arisu  	| `x86_64-linux`                 	| primary development tower, custom built   	|
| kokoro 	| `x86_64-linux`                 	| ThinkBook 15 laptop, mobile development   	|
| chibi 	| `aarch64-linux`                	| Raspberry Pi 4B for hosting and local dev 	|
| hikari 	| `x86_64-linux`                	| custom installer ISO, new systems and VMs 	|


## Installation

To set up your system using the Symphony configurations, follow these steps:

```bash
git clone https://github.com/c4patino/nixos-configuration.git ~/dotfiles
cd ~/dotfiles

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
    --mode disko ~/dotfiles/hosts/<system>/disko.nix --arg device '"/dev/<device>"'

cp ~/dotfiles /mnt/persist

cp ~/dotfiles /mnt/etc/nixos
sudo nixos-install --root /mnt --flake /mnt/etc/nixos#<system>
```
    
## Features

- Dynamic backgrounds: Variety-powered slideshow for ever-changing wallpapers.
- Development environments: Preconfigured setups for various programming languages.
- Neovim: Highly customized configuration for efficient coding.
- Various editors: Native Vim shortcut support and configurations.
- Yazi: Fast, terminal-based file manager.
- Eww task bar: Minimal and versatile task bar interface.
- Spotify: Seamless Spotify integration.
- Anyrun: Intuitive application launcher.
- Kitty terminal: Customized themes and keybindings.
- Zoxide: Enhanced terminal navigation with zoxide.


## Roadmap
- impermanence configuration to prevent over-time pollution of directories


## Authors

- [@c4patino](https://www.github.com/c4patino)


## Related

Here are some related projects that are used in this configuration

[neovim-config](https://github.com/c4patino/neovim-config)
[nixvim-config](https://github.com/c4patino/nixvim-config)
[dotfiles](https://github.com/c4patino/dotfiles)


## License

[MIT](https://choosealicense.com/licenses/mit/)

