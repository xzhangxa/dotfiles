#!/bin/bash

echo "=== Install necessary packages ==="
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew install tmux neovim htop rsync clang-format cloc ranger cmake wget trash-cli

echo "=== Setup oh-my-zsh ==="
sh -c "CHSH=no RUNZSH=no $(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

echo "=== Copy config files ==="
mkdir -p ~/.config/nvim
cp $(dirname "$0")/init.vim ~/.config/nvim
cp $(dirname "$0")/zshrc ~/.zshrc
cp $(dirname "$0")/p10k.zsh ~/.p10k.zsh
cp $(dirname "$0")/tmux.conf ~/.tmux.conf
cp $(dirname "$0")/gitconfig ~/.gitconfig

echo "=== Setup fzf ==="
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

echo "=== Setup neovim, vim-plug and plugins ==="
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
nvim +PlugInstall +qall
nvim +'LspInstall --sync clangd rust_analyzer' +qall

echo "=== Setup rust and tools from cargo ==="
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > sh.rustup.rs
sh ./sh.rustup.rs -y --no-modify-path && rm ./sh.rustup.rs
source ~/.cargo/env
cargo install ripgrep bat exa fd-find

echo "remember to relogin."
echo "Bye Bye."
