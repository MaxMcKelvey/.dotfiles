# .dotfiles

## Instructions for zsh

1. Source .dotfiles/.zshrc
2. Follow the powerlevel10k setup instructions
3. Put `source ~/.dotfiles/.zshrc` at the top of your .zshrc file
4. Install zoxide (`brew install zoxide` or with your linux package manager)
5. Install fzf
6. Install tmux
7. Install nvim

## Instructions for nvim

1. `ln -s ~/.dotfiles/.config/nvim ~/.config/nvim` to softlink your nvim config into your .config dir
2. `n .` to open neovim
3. `git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim`
4. `:q` and `n .` to reopen neovim
5. `:PackerSync` to install packages with packer

## Instructions for tmux

1. `ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf`
2. run `tmux` to start your tmux session

<br/>
---

## Condensed instructions for Ubuntu

```sh
sudo apt update
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt install zsh build-essential neovim tmux fzf zoxide -y

# if you also need node
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

## Caps Lock to Escape Instructions (Windows)

Go to [https://www.autohotkey.com/](https://www.autohotkey.com/), download V2, and do the installation.

Right click in finder, and click new -> autohotkey script.

Open with terminal and paste in:

```ahk
#Requires AutoHotkey v2.0
; Make Caps Lock act as Escape unless Shift is held (AHK v2)

CapsLock:: {
    if GetKeyState("Shift", "P")
        Send("{CapsLock}")  ; If Shift is held, send normal CapsLock
    else
        Send("{Escape}")    ; Otherwise, send Escape
}
```

Double click to run!

Press `Win + R` → type `shell:startup` → Enter.

Copy the script into this folder for it to run on startup!
