# ゆめあみ (yumeami)

![logo](./demo.png)

Meticulously crafted collection of NixOS configurations tailored for my
systems. This repository encapsulates a unified setup across different
machines, ensuring a consistent and efficient environment no matter where I'm
working. The configurations are designed with modularity and clarity in mind,
making it easy to adapt and scale. Whether it's setting up a new machine or
refining an existing setup, ゆめあみ brings what I believe to be the best
practices in NixOS configuration management, unified under a single, cohesive
structure.

| System      | Architecture     | Description                                      |
|-------------|------------------|--------------------------------------------------|
| 🧠 arisu    | `x86_64-linux`   | primary development tower, custom built          |
| 🌙 tsuki    | `x86_64-linux`   | 4U ATX rack server, networking and core services |
| 💖 kokoro   | `x86_64-linux`   | thinkBook 15 laptop, mobile development          |
| 🌸 shiori   | `x86_64-linux`   | always-on mini pc, torrents and DNS services     |
| 🐣 chibi    | `aarch64-linux`  | raspberry Pi 4B for hosting and local dev        |
| ✨ hikari   | `x86_64-linux`   | custom installer iso, new systems and VMs        |

## Repository Structure

```
.
├── flake.nix              # Main flake configuration
├── homes/                 # Home-manager configurations
│   ├── aarch64-linux/     # ARM architecture systems
│   └── x86_64-linux/      # x86 architecture systems
├── lib/                   # Shared library functions
├── modules/               # Modular configurations
│   ├── home/              # Home-manager modules
│   └── nixos/             # NixOS system modules
├── secrets/               # Encrypted secrets (git-crypt)
├── shells/                # Development shell environments
└── systems/               # NixOS system configurations
```

## Prerequisites

- NixOS installation media
- ZFS support (for impermanence)
- A storage device to install to
- Basic understanding of NixOS and the Nix language

## Installation

To set up your system using ゆめあみ configurations:

```bash
# Clone the repository
git clone https://github.com/c4patino/yumeami.git ~/dotfiles
cd ~/dotfiles

# Unlock git-crypt secrets if you have the key (age keys, sops files)
git-crypt unlock

# Partition and format drives using disko
# Replace <device> with your disk device (e.g., sda, nvme0n1)
sudo nix --experimental-features "flakes nix-command pipe-operators" run github:nix-community/disko -- \
    --mode disko ~/dotfiles/systems/disko.nix \
    --arg main '"/dev/<device>"'
sudo zfs snapshot zroot/root@blank

# Copy configuration to the persistent storage
sudo cp ~/dotfiles /mnt/persist

# Install NixOS with the configuration for your system
# Replace <system-name> with one of: arisu, kokoro, shiori, chibi, tsuki
sudo nixos-install --root /mnt --flake ~/dotfiles#<system-name> --option extra-experimental-features "flakes nix-command pipe-operators"
```

### Installing a WSL Host

WSL hosts (e.g. `arisu-windows`, `kokoro-windows`) skip disko and
`nixos-install` entirely. They start from the stock NixOS-WSL distro
(built-in `nixos` user) and are converted in place with
`nixos-rebuild switch`. In PowerShell:

```powershell
wsl --install -d NixOS
```

Then, inside the fresh distro:

```bash
# Clone the repository
git clone https://github.com/c4patino/yumeami.git ~/dotfiles
cd ~/dotfiles

# Unlock git-crypt secrets if you have the key (age keys, sops files)
git-crypt unlock

# Replace <hostname>-windows with e.g. arisu-windows or kokoro-windows
# (the stock NixOS-WSL distro needs the experimental-features flags explicitly)
sudo nixos-rebuild switch --flake .#<hostname>-windows --option extra-experimental-features "flakes nix-command pipe-operators"
```

No `hardware-configuration.nix` or disko layout is needed — the `nixos-wsl`
module manages the bootloader and filesystems. The matching home configuration
(`c4patino@<hostname>-windows`) is attached automatically and applied as part
of the switch after the first rebuild.

### Installing with nixos-anywhere

Instead of booting the installer by hand, you can install a machine remotely
over SSH with
[nixos-anywhere](https://github.com/nix-community/nixos-anywhere). Since disko
is already wired into every host configuration, nixos-anywhere picks up the
layout automatically — no extra disko arguments needed.

Requirements:

- The target machine is reachable over SSH as `root` (key-based auth; the kexec
  stage does not support Wi-Fi)
- It is running a Linux distro with kexec support and at least 1 GB of RAM, or
  it has booted the [hikari](#building-the-installer-iso-hikari) ISO
- The disk devices hardcoded in `systems/<arch>/<hostname>/default.nix` (e.g.
  `/dev/nvme0n1`) match the target machine
- `git-crypt unlock` has been run locally so the build can read secrets

```bash
# 1. kexec into the NixOS installer, then partition and mount with disko
nix run github:nix-community/nixos-anywhere -- \
  --flake ~/dotfiles#<hostname> \
  --target-host root@<ip-address> \
  --phases kexec,disko

# 2. Create the blank ZFS snapshot that impermanence rolls back to on boot
ssh root@<ip-address> zfs snapshot zroot/root@blank

# 3. Install NixOS into /mnt and reboot into the new system
nix run github:nix-community/nixos-anywhere -- \
  --flake ~/dotfiles#<hostname> \
  --target-host root@<ip-address> \
  --phases install,reboot
```

Useful flags:

- `--build-on remote`: build the closure on the target instead of locally
  (useful when cross-installing `chibi` from an x86_64 machine)
- `--generate-hardware-config nixos-generate-config ./hardware-configuration.nix`:
  regenerate the hardware config during install
- `--kexec <path>`: custom kexec tarball — needed for architectures other
  than x86_64/aarch64, or targets that require VPN access during kexec
- `--vm-test`: dry-run the whole install in a local VM first

If the target is already running the [hikari](#building-the-installer-iso-hikari)
installer (no kexec needed), drop the kexec phase: use `--phases disko` for
step 1 and `--phases install,reboot` for step 3.

### Building the Installer ISO (hikari)

`hikari` is a custom installer image built with the modern
`nixos-rebuild build-image` flow (which replaced `nixos-generators`). It
bundles tools like `disko`, `git`, `nh`, and `parted` for installing new
systems and VMs:

```bash
# Build the ISO with nixos-rebuild (writes result/ in the current directory)
sudo nixos-rebuild build-image --flake ~/dotfiles#hikari --image-variant installer-minimal
```

The resulting image lands in `result/iso/nixos-hikari-*-x86_64-linux.iso`.
Write it to a USB stick (replace `sdX` with your device):

```bash
dd if=result/iso/nixos-hikari-*-x86_64-linux.iso of=/dev/sdX status=progress
sync
```


## Customization

To customize a configuration for your own use:

1. Create a new host configuration in `systems/<arch>/<hostname>/default.nix`
2. Configure your hardware settings in `systems/<arch>/<hostname>/hardware-configuration.nix`
3. Create a home-manager configuration in `homes/<arch>/<user>@<hostname>/default.nix`
4. Enable the desired modules for your system and home configurations

## Features

- **Impermanence**: ZFS snapshot-based system with persistent directories for clean reboots
- **Dynamic backgrounds**: Variety-powered slideshow for ever-changing wallpapers
- **Development environments**: Preconfigured setups for various programming languages
- **Neovim**: Highly customized configuration for efficient coding
- **Various editors**: Native Vim shortcut support and configurations
- **Yazi**: Fast, terminal-based file manager
- **Eww task bar**: Minimal and versatile task bar interface
- **Spotify**: Seamless Spotify integration
- **Anyrun**: Intuitive application launcher
- **Kitty terminal**: Customized themes and keybindings
- **Zoxide**: Enhanced terminal navigation with zoxide

## Formatter Setup

This project uses [treefmt-nix](https://github.com/numtide/treefmt-nix) to orchestrate formatters for Nix and Lua files:

- **alejandra** for Nix
- **stylua** for Lua

### Usage

#### Format all files

```sh
nix fmt
```

#### Check formatting (for CI or local validation)

```sh
nix flake check
```

### Configuration

Formatters are configured in `flake.nix` and `treefmt.nix`.

- To add more formatters, edit `treefmt.nix` and update the `programs` section.

### Troubleshooting

If you encounter issues, ensure your Nix version is up to date (2.25+ recommended).

For more info, see [treefmt-nix documentation](https://github.com/numtide/treefmt-nix).

## Usage

### Rebuilding Your System

```bash
# For system configuration
sudo nixos-rebuild switch --flake ~/dotfiles#<hostname>

# For home-manager configuration
home-manager switch --flake ~/dotfiles#<user>@<hostname>
```

### Adding New Modules

1. Create a new module in the appropriate directory:
   - System modules: `modules/nixos/<category>/<module-name>/`
   - Home modules: `modules/home/<category>/<module-name>/`
2. Create a `default.nix` file following the existing module structure
3. Enable your module in your system or home configuration

## Troubleshooting

### Common Issues

- **ZFS import fails**: Ensure you have the correct pool name in your configuration
- **Module not found**: Check that the module is correctly imported and the namespace is correct
- **Secrets not accessible**: Run `git-crypt unlock` if you have access to the repository keys

## Roadmap

- Add comprehensive module test coverage
- Implement integration tests with virtual machines
- Add performance benchmarking for critical configurations

## Authors

- [@c4patino](https://www.github.com/c4patino)

## Related

Here are some related projects that are used in this configuration

- [neovim-config](https://github.com/c4patino/neovim-config)
- [nixvim-config](https://github.com/c4patino/nixvim-config)
- [dotfiles](https://github.com/c4patino/dotfiles)

## License

[MIT](https://choosealicense.com/licenses/mit/)
