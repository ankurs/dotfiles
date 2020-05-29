#!/bin/bash
pip install pynvim bashate --user --upgrade
pip install python-language-server[all] --user
npm i -g typescript-language-server bash-language-server
pip install vim-vint --user --upgrade
go get -u golang.org/x/tools/...
go get -u github.com/stamblerre/gocode
