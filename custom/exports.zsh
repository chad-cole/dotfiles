# You can put files here to add functionality separated per file, which
# will be ignored by git.
# Files on the custom/ directory will be automatically loaded by the init
# script, in alphabetical order.

# Highlight section titles in manual pages
export LESS_TERMCAP_md="$ORANGE"

# Larger bash history (allow 32³ entries; default is 500)
export HISTFILE=.oh-my-zsh/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

# Make some commands not show up in history
export HISTORY_IGNORE="ls:cd:cd -:pwd:exit:date:* --help"

# colorful colors in iterm
export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd

export LANG=en_US.utf8
