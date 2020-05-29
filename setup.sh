#!/bin/bash -e

UPDATE=""

if [[ ! -z "$1" ]]
then
    UPDATE="yes"
fi

function setup_mac() {
    echo "setting up mac"
    brew cask install java
    cat ./brew_tap | xargs -L 1 brew tap
    cat ./brew_list | xargs -L 1 brew install
    cat ./brew_cask_list | xargs -L 1 brew cask install
}

function setup_fedora() {
    if [[ -z $UPDATE ]]
    then
        echo "Setting up Fedora"
        sudo systemctl enable sshd
        sudo systemctl start sshd
        echo "setting up RPM Fusion"
        sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y
        sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
    fi

    grep -q -F 'fastestmirror=True' /etc/dnf/dnf.conf
    if [[ $? -ne 0 ]]
    then
      echo 'fastestmirror=True' | sudo sudo tee --append /etc/dnf/dnf.conf
    fi
    sudo dnf update-minimal -y
    echo "setting up Development Tools"
    sudo dnf groupinstall "Development Tools" -y
    sudo dnf install cmake make python-devel vim zsh gcc-c++ -y
    echo "installing snap"
    sudo dnf install -y snapd
    if [[ -z $UPDATE ]]
    then
        sudo ln -s -i /var/lib/snapd/snap /snap
    fi
    cat ./dnf_list | xargs -L 10 sudo dnf install -y
    echo "waiting for snap to seed"
    sudo snap wait system seed.loaded
    cat ./snap_list | xargs -L 1 sudo snap install

    echo "setting up awesome wm"
    sudo cp ./fedora/sp /usr/local/bin/
    ln -s -i `pwd`/awesome ~/.config/awesome
    ln -s -i `pwd`/fedora/dot-Xresources ~/.Xresources
    bash -e fedora_post_setup.sh
}

function do_setup() {
    if [[ $(uname) == "Darwin" ]]
    then
        setup_mac
    fi

    if [[ $(uname) == "Linux" ]]
    then
        if [[ -f /etc/os-release ]]
        then
            source /etc/os-release
            if [[ $NAME == "Fedora" ]]
            then
                setup_fedora
            fi
        fi
    fi
}

git submodule init
git submodule update --init --recursive

if [[ -z $UPDATE ]]
then
    bash fonts/install.sh
    PWD=`pwd`
    ln -s -i $PWD/dot-profile ~/.profile
    ln -s -i $PWD/dot-tmux.conf ~/.tmux.conf
    ln -s -i $PWD/dot-vimrc ~/.vimrc
    ln -s -i $PWD/dot-zshrc ~/.zshrc
    ln -s -i $PWD/dot-tmux-powerlinerc ~/.tmux-powerlinerc
    ln -s -i $PWD/dot-mostrc ~/.mostrc
    ln -s -i $PWD/dotgitconfig ~/.gitconfig
    ln -s -i $PWD/dot-gitignore ~/.gitignore
    mkdir -p ~/.config/nvim/
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    ln -s -i ~/.vimrc ~/.config/nvim/init.vim
else
    echo "Update requested skipping initial setup"
fi

do_setup

bash ./setup_lang_server.sh

nvim +PlugInstall +qall
## install java 1.8
#jabba install zulu@1.8
if [[ ! -z $UPDATE ]]
then
    nvim '+PlugClean!' +PlugUpdate +PlugUpgrade +qall
fi
