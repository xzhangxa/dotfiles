#!/bin/bash

echo "=== Setup proxy ==="
if [ "$1" != "" ]; then
	export http_proxy=$1
	export https_proxy=$1
	export HTTP_PROXY=$1
	export HTTPS_PROXY=$1
	git config --global http.proxy $1
        sudo bash -c "cat<<EOF >> /etc/environment
http_proxy=\"$http_proxy\"
https_proxy=\"$https_proxy\"
EOF"
        #sudo bash -c "cat<<EOF >> /etc/apt/apt.conf
#Acquire::http::proxy \"$1\";
#Acquire::https::proxy \"$1\";
#EOF"
        mkdir ~/bin
        cat<<EOF >> ~/bin/git-proxy
#!/bin/sh
PROXY=${1%:*}
exec socat STDIO SOCKS4:\$PROXY:\$1:\$2
EOF
else
	echo "no proxy is given"
fi

echo "=== Install necessary packages ==="
sudo apt-get update
sudo apt-get install -y aptitude openssh-server git tmux vim vim-nox zsh curl indent cloc cscope build-essential autoconf gdb cmake cmake-curses-gui wget trash-cli python3-dev

echo "=== Setup GDB ==="
wget https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/master/.gdbinit -O ~/.gdbinit
mkdir ~/.gdbinit.d
cat<<EOF > ~/.gdbinit.d/dashboard
dashboard -style prompt_not_running '\[\e[1;31m\]>>>\[\e[0m\]'
dashboard -style style_low '1;31'
dashboard -style syntax_highlighting 'vim'
dashboard -layout source stack threads memory history expressions !assembly !registers
dashboard source -style context 15
dashboard stack -style compact True
dashboard stack -style limit 5
EOF

echo "=== Setup oh-my-zsh ==="
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sed /env\ zsh/d)"
sudo chsh -s /bin/zsh $USER
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "=== Download config files ==="
git clone https://github.com/zhang-xin/my-config-files.git
cp my-config-files/.vimrc ~
cp my-config-files/.zshrc ~
cp my-config-files/.tmux.conf ~
cp my-config-files/.gitconfig ~
cp my-config-files/.dir_colors ~
mkdir ~/bin
cp my-config-files/dgdb ~/bin
rm -rf my-config-files

echo "=== Setup Universal ctags ==="
git clone https://github.com/universal-ctags/ctags.git
cd ctags
./autogen.sh
./configure
make
sudo make install
cd ..
rm -rf ctags

echo "=== Setup vim-plug and vim plugins ==="
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall
sed -i 's/colorscheme ron/colorscheme solarized/' ~/.vimrc

echo "remember to relogin and change proxy setting in .gitconfig and .zshrc."
echo "Bye Bye."
