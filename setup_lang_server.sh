#!/bin/bash
pip install pynvim bashate --user --upgrade
pip install python-language-server[all] --user --upgrade
npm i -g typescript-language-server bash-language-server --upgrade
pip install vim-vint --user --upgrade
go get -u golang.org/x/tools/...
go get -u github.com/stamblerre/gocode

curl -fLo ~/.java-lang-server/jdt-language-server-latest.tar.gz --create-dir http://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz

rustup toolchain add nightly
cargo +nightly install racer
rustup default nightly
