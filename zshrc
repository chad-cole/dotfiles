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

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/chadcole/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/chadcole/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/chadcole/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/chadcole/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

plugins=(git vi-mode python osx brew virtualenv zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

