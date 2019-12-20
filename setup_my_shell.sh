#!/bin/bash

echo "=== Install necessary packages ==="
sudo -E apt-get update
sudo -E apt-get install -y aptitude openssh-server git tmux vim vim-nox zsh htop curl rsync clang-format cloc cscope tree build-essential autoconf gdb cmake cmake-curses-gui pkg-config wget trash-cli python3-dev

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
sh -c "RUNZSH=no $(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "=== Download config files ==="
git clone https://github.com/zhang-xin/my-config-files.git
cp my-config-files/.vimrc ~
cp my-config-files/.zshrc ~
cp my-config-files/.tmux.conf ~
cp my-config-files/.gitconfig ~
cp my-config-files/.dir_colors ~
mkdir ~/bin
mkdir ~/.vim
cp my-config-files/dgdb ~/bin
cp my-config-files/.ycm_extra_conf.py ~/.vim/.ycm_extra_conf.py
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

echo "remember to relogin."
echo "Bye Bye."
