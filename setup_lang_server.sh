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
pip3 install pynvim bashate --user --upgrade
pip3 install python-language-server[all] --user --upgrade
npm i -g typescript-language-server bash-language-server neovim --upgrade
pip3 install vim-vint --user --upgrade

#curl -fLo ~/.java-lang-server/jdt-language-server-latest.tar.gz --create-dir http://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz

PATH="$HOME/.cargo/bin:$PATH"
if [[ ! -x $(which rustup) ]]
then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
rustup component add rust-src
rustup component add rust-analyzer
cargo +nightly install racer
#rustup default nightly

gem install neovim
pip install neovim --user --upgrade
pip3 install neovim --user --upgrade
python3 -m pip install neovim --user --upgrade

npm install vls -g
npm i -g eslint eslint-plugin-vue
