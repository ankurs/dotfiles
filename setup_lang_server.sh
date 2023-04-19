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

if [[ ! -d ~/.java-lang-server ]]
then
    mkdir ~/.java-lang-server
    mkdir ~/.java-lang-server/data
    curl -fLo ~/.java-lang-server/jdt-language-server-latest.tar.gz --create-dir http://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz

    cd ~/.java-lang-server
    tar -xvzf jdt-language-server-latest.tar.gz
    rm jdt-language-server-latest.tar.gz
    cd -

    # make run.sh
    dist="linux"
    if [[ $(uname) = 'Darwin' ]]
    then
        dist="mac"
    fi
    run="java \
	-Declipse.application=org.eclipse.jdt.ls.core.id1 \
	-Dosgi.bundles.defaultStartLevel=4 \
	-Declipse.product=org.eclipse.jdt.ls.core.product \
	-Dlog.level=ALL \
	-Xmx1G \
	--add-modules=ALL-SYSTEM \
	--add-opens java.base/java.util=ALL-UNNAMED \
	--add-opens java.base/java.lang=ALL-UNNAMED \
    -jar ~/.java-lang-server/plugins/$(ls ~/.java-lang-server/plugins | grep org.eclipse.equinox.launcher_) \
    -configuration ./config_$dist \
    -data ~/.java-lang-server/data"
    echo $run > ~/.java-lang-server/run.sh
    chmod +x ~/.java-lang-server/run.sh
fi

PATH="$HOME/.cargo/bin:$PATH"
if [[ ! -x $(which rustup) ]]
then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
rustup component add rust-src
rustup component add rust-analyzer
#cargo +nightly install racer
#rustup default nightly

gem install neovim
pip install neovim --user --upgrade
pip3 install neovim --user --upgrade
python3 -m pip install neovim --user --upgrade

npm install vls -g
npm i -g eslint eslint-plugin-vue
