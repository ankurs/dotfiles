#!/bin/bash
ln dot-profile ~/.profile
ln ./dot-tmux.conf ~/.tmux.conf
ln ./dot-vimrc ~/.vimrc
ln ./dot-zshrc ~/.zshrc
ln ./dot-tmux-powerlinerc ~/.tmux-powerlinerc
mkdir -p ~/.vim/bundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
python ~/.vim/bundle/YouCompleteMe/install.py
brew cask install java
cat ./brew_tap | xargs -n 1 brew tap
cat ./brew_list | xargs -n 1 brew install
cat ./brew_cask_list | xrags -n 1 brew cask install
vim +GoUpdateBinaries
