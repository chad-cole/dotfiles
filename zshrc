export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="powerlevel10k/powerlevel10k"
source ~/dotfiles/custom/p10k-theme

plugins=(git vi-mode python osx brew virtualenv zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nvim'
 else
   export EDITOR='nvim'
 fi

source /opt/homebrew/opt/asdf/asdf.sh
