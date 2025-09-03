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

