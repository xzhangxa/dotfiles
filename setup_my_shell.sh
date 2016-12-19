#!/bin/bash

echo "=== Setup proxy ==="
if [ -n "$1" ]; then
	export http_proxy=$1
	export https_proxy=$1
	export HTTP_PROXY=$1
	export HTTPS_PROXY=$1
	git config --global http.proxy $1
	sudo echo "Acquire::http::proxy \"$1\";" > /etc/apt/apt.conf
	sudo echo "Acquire::https::proxy \"$1\";" >> /etc/apt/apt.conf
else
	echo "no proxy is given"
fi

echo "=== Install necessary packages ==="
sudo apt-get update
sudo apt-get install aptitude openssh-server git tmux vim vim-nox zsh curl indent cloc ctags cscope build-essential gdb cmake cmake-curses-gui wget

echo "=== Setup oh-my-zsh ==="
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sed /env\ zsh/d)"
sudo chsh -s /bin/zsh xzhang84

echo "=== Download config files ==="
git clone https://github.com/zhang-xin/my-config-files.git
cp my-config-files/.vimrc ~
cp my-config-files/.zshrc ~
cp my-config-files/.tmux.conf ~
cp my-config-files/.gitconfig ~
cp my-config-files/.dir_colors ~
rm -rf my-config-files

echo "=== Setup Vundle and vim plugins ==="
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
sudo apt-get install libpython3-dev
cd ~/.vim/bundle/YouCompleteMe
./install.py --clang-completer

echo "remember to relogin and change proxy setting in .gitconfig and .zshrc."
echo "Bye Bye."
