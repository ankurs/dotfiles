#!/bin/bash
if [[ ! -x $(which pip) ]]
then
    if [[ $(uname) = 'Darwin' ]]
    then
        sudo easy_install pip
    else
        easy_install pip
    fi
fi
pip install pynvim bashate --user --upgrade
pip install python-language-server[all] --user --upgrade
npm i -g typescript-language-server bash-language-server neovim --upgrade
pip install vim-vint --user --upgrade
go get -u golang.org/x/tools/...
go get -u github.com/stamblerre/gocode

curl -fLo ~/.java-lang-server/jdt-language-server-latest.tar.gz --create-dir http://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz

PATH="$HOME/.cargo/bin:$PATH"
if [[ ! -x $(which rustup) ]]
then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
rustup toolchain add nightly
cargo +nightly install racer
rustup default nightly

gem install neovim
pip install neovim --user --upgrade
pip3 install neovim --user --upgrade
python3 -m pip install neovim --user --upgrade

#brew install borkdude/brew/clj-kondo
