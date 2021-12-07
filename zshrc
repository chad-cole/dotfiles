export PATH=$(`echo brew --prefix`)/bin:$(`echo brew --prefix`)sbin:$PATH
export PATH=$(`echo brew --prefix llvm`)/bin:$PATH
source $(`echo brew --prefix`)/opt/asdf/asdf.sh
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="powerlevel10k/powerlevel10k"
source ~/dotfiles/custom/p10k-theme

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nvim'
 else
   export EDITOR='nvim'
 fi

source $(`echo brew --prefix`)/opt/asdf/asdf.sh

plugins=(git vi-mode python macos brew virtualenv zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
export GPG_TTY=$(tty)

[[ -f /opt/dev/sh/chruby/chruby.sh ]] && type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; }

[ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh
