#!/bin/bash
git submodule init
git submodule update
bash fonts/install.sh
PWD=`pwd`
ln -s $PWD/dot-profile ~/.profile
ln -s $PWD/dot-tmux.conf ~/.tmux.conf
ln -s $PWD/dot-vimrc ~/.vimrc
ln -s $PWD/dot-zshrc ~/.zshrc
ln -s $PWD/dot-tmux-powerlinerc ~/.tmux-powerlinerc
ln -s $PWD/dotgitconfig ~/.gitconfig
mkdir -p ~/.config/nvim/
mkdir -p ~/.vim/bundle
ln -s ~/.vimrc ~/.config/nvim/init.vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
python ~/.vim/bundle/YouCompleteMe/install.py
brew cask install java
cat ./brew_tap | xargs -n 1 brew tap
cat ./brew_list | xargs -n 1 brew install
cat ./brew_cask_list | xargs -n 1 brew cask install
vim +GoUpdateBinaries +qall
pip install neovim
pip install bashate

