# Dotfiles

## I like NeoVim and Tmux - here is how I set them up on a new device

### Install Conda (OSX Bash Script)
[Conda](https://docs.conda.io/en/latest/miniconda.html)

### Download Dependencies (OSX)
```
brew install node
brew install yarn
brew install asdf
brew install --HEAD neovim
pip install neovim
npm install -g typescript
brew install ripgrep
```

### Install Ruby (OSX)
 [Using ASDF](https://andrewm.codes/blog/how-to-install-ruby-on-rails-6-1-with-asdf-on-macos-big-sur)

### Run install script
`./install`

### Download LSP Servers
```
brew install llvm
pip install python-language-server
gem install solargraph
npm install typescript-language-server
```
### Download Tree Sitter Engines
Open nvim
```vim
:TSInstall python
:TSInstall ruby
:TSInstall typescript
:TSInstall c
:TSInstall rust
:TSInstall lua
:TSInstall verilog
:TSInstall latex
:TSInstall yaml
:TSInstall regex
```


