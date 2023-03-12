#!/bin/bash

UPDATE=""

if [[ ! -z "$1" ]]
then
    UPDATE="yes"
fi

function setup_mac() {
    echo "setting up mac"
    if [[ ! -x $(which brew) ]]
    then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi
    echo "disabling lowpri_throttle to speed up tasks like timemachine backup"
    sudo sysctl debug.lowpri_throttle_enabled=0
    #brew cask install java
    cat ./brew_tap | xargs -L 1 brew tap
    cat ./brew_list | xargs -L 10 brew install
    brew install --HEAD universal-ctags/universal-ctags/universal-ctags
    cat ./brew_cask_list | xargs -L 5 brew install
}

function setup_fedora() {
    echo "Setting up Fedora"
    set +e
    grep -q -F 'fastestmirror=True' /etc/dnf/dnf.conf
    if [[ $? -ne 0 ]]
    then
      echo 'fastestmirror=True' | sudo sudo tee --append /etc/dnf/dnf.conf
    fi
    set -e

    if [[ -z $UPDATE ]]
    then
        sudo systemctl enable sshd
        sudo systemctl start sshd
        echo "setting up RPM Fusion"
        sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
        sudo dnf groupupdate core -y
        sudo dnf update-minimal -y
        echo "setting up Development Tools"
        sudo dnf groupinstall "Development Tools" -y
        sudo dnf install cmake make python-devel vim neovim zsh gcc-c++ -y
        echo "installing snap"
        sudo dnf install -y snapd
        sudo ln -s -i /var/lib/snapd/snap /snap
        echo "waiting for snap to seed"
        sudo snap wait system seed.loaded
    fi

    sudo dnf upgrade -y
    cat ./dnf_list | xargs -L 20 sudo dnf install -y
    #cat ./snap_list | xargs -L 1 sudo snap install

    if [[ -z $UPDATE ]]
    then
        bash -e fedora_post_setup.sh
    fi
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
            if [[ $NAME == "Fedora Linux" ]]
            then
                setup_fedora
            fi
        fi
    fi
}

if [[ ! -f $HOME/.ssh/id_rsa.pub ]]
then
    ssh-keygen -t rsa
fi

cat $HOME/.ssh/id_rsa.pub
read -p "Please make sure github is updated with the ssh key of this system" discard

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
    ln -s -i $PWD/dot-todo.cfg ~/.todo.cfg
    mkdir -p ~/.cargo/
    ln -s -i $PWD/cargo-config ~/.cargo/config
    mkdir -p ~/.config/nvim/
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    ln -s -i ~/.vimrc ~/.config/nvim/init.vim
else
    echo "Update requested skipping initial setup"
fi

do_setup

npm i -g neovim --upgrade
gem install neovim
nvim +PlugInstall +qall
## install java 1.8
#jabba install zulu@1.8
nvim '+PlugClean!' +PlugUpdate +PlugUpgrade +qall

bash ./setup_lang_server.sh
