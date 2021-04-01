# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/chadcole/opt/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/chadcole/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/chadcole/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/chadcole/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

### Disable default conda env print line
conda config --set changeps1 False
