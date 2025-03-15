#!/bin/bash
# author: weiensong
# email: touer0018@gmail.com

OS_TYPE=$(uname)
ZHS_PATH=$(which zsh)

export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"

if [ "$OS_TYPE" = "Darwin" ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew install git fzf tmux the_silver_searcher git-delta
  if [ -z "$ZHS_PATH" ]; then
    brew install zsh
  else
    echo "zsh already installed at $ZHS_PATH, skipping installation."
  fi
elif [ "$OS_TYPE" = "Linux" ]; then
  if [ -z "$ZHS_PATH" ]; then
    sudo apt update && sudo apt upgrade -y
    sudo apt install zsh git fzf tmux silversearcher-ag git-delta -y
    latest_tag=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    deb_url="https://github.com/dandavison/delta/releases/download/${latest_tag}/git-delta_${latest_tag#v}_amd64.deb"
    curl -LO "$deb_url"
    sudo dpkg -i "git-delta_${latest_tag#v}_amd64.deb"
    rm "git-delta_${latest_tag#v}_amd64.deb"
  else
    echo "zsh already installed at $ZHS_PATH, skipping installation."
    exit
  fi
else
  echo "Unknown OS: $OS_TYPE"
  exit 1
fi

if [ -n "$ZHS_PATH" ]; then
  chsh -s "$ZHS_PATH"
fi

git config --global user.name "touero"
git config --global user.email "touer0018@gmail.com"
git config --global color.ui auto
git config --global diff.tool nvimdiff
git config --global difftool.prompt false
git config --global sendemail.suppresscc self
git config --global delta.navigate true
git config --global delta.line-numbers true
git config --global delta.side-by-side true
git config --global delta.syntax-theme gruvbox-dark

wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

curl -sS https://starship.rs/install.sh | sh

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting &&
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions &&
  git clone https://github.com/hlissner/zsh-autopair ~/.oh-my-zsh/plugins/zsh-autopair &&
  sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf zsh-autopair tmux ag fd zsh-interactive-cd)/g' ~/.zshrc

sed -i '/# Example aliases/a\ if [ -f ~/.my_aliases.zsh ]; then\n  source ~/.my_aliases.zsh\nfi' ~/.zshrc

sed -i '/# export LANG=en_US.UTF-8/a\
export EDITOR="nvim"\n\
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"\n\
export DISABLE_FZF_AUTO_COMPLETION="true"\n\
export FZF_COMPLETION_TRIGGER="\\\n"\n\
export FZF_DEFAULT_COMMAND="fd --type f"\n\
export DISABLE_FZF_KEY_BINDINGS="true"\n\
export RANGER_LOAD_DEFAULT_RC=FALSE
' ~/.zshrc

zsh
