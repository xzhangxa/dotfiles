#!/bin/bash

echo "=== Install necessary packages ==="
sudo -E apt-get update
sudo -E apt-get install -y \
            aptitude openssh-server git tmux zsh htop curl wget rsync socat ranger trash-cli xclip \
            build-essential autoconf gdb cmake cmake-curses-gui pkg-config clang-format cloc \
            fuse command-not-found lsb-release

sudo apt-file update && sudo update-command-not-found

echo "=== Setup GDB ==="
wget https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/master/.gdbinit -O ~/.gdbinit
mkdir ~/.gdbinit.d
cp $(dirname "$0")/gdb_dashboard ~/.gdbinit.d/dashboard

echo "=== Setup oh-my-zsh ==="
sh -c "CHSH=no RUNZSH=no $(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

echo "=== Copy config files ==="
mkdir -p ~/.config/nvim
head -50 $(dirname "$0")/init.vim > ~/.config/nvim/init.vim
cp $(dirname "$0")/zshrc ~/.zshrc
cp $(dirname "$0")/p10k.zsh ~/.p10k.zsh
cp $(dirname "$0")/tmux.conf ~/.tmux.conf
cp $(dirname "$0")/gitconfig ~/.gitconfig
mkdir -p ~/.local/bin
cp ./dgdb ~/.local/bin
cp ./git-proxy ~/.local/bin

echo "=== Setup fzf ==="
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

echo "=== Setup neovim, vim-plug and plugins ==="
wget https://github.com/neovim/neovim/releases/download/stable/nvim.appimage -O ~/.local/bin/nvim
chmod +x ~/.local/bin/nvim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
~/.local/bin/nvim +PlugInstall +qall
~/.local/bin/nvim +'LspInstall --sync clangd rust_analyzer' +qall
cp $(dirname "$0")/init.vim ~/.config/nvim/init.vim

echo "=== Setup rust and tools from cargo ==="
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > sh.rustup.rs
sh ./sh.rustup.rs -y --no-modify-path && rm ./sh.rustup.rs
source ~/.cargo/env
cargo install ripgrep bat exa fd-find

echo "remember to relogin."
echo "Bye Bye."
