# Dotfiles

## I like NVim and Tmux - here is how I set them up on a new device

### Download Dependencies (OSX)
```
brew install node
brew install yarn
brew install ruby
```
### Run install script
`./install`
### Download LSP Servers
```
pip install python-language-server
gem install solargraph
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


