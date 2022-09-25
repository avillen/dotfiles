#!/bin/zsh

remove_old_dotfiles(){
  echo "Removing old dotfiles"

  rm $HOME/.aliases
  rm $HOME/.gitignore
  rm $HOME/.tmux.conf
  rm $HOME/.zshrc
  rm -rf $HOME/.snippets
  rm -rf $HOME/.git
  rm -rf $HOME/.vim

  echo "Dotfiles removed"
}

create_sym_lynk(){
  echo "Creating new dotfiles"

  ln -s $HOME/dotfiles/.aliases ~/.aliases
  ln -s $HOME/dotfiles/.gitignore ~/.gitignore
  ln -s $HOME/dotfiles/.tmux.conf ~/.tmux.conf
  ln -s $HOME/dotfiles/.zshrc ~/.zshrc
  ln -s $HOME/dotfiles/.snippets ~/.snippets
  ln -s $HOME/dotfiles/init.lua ~/.config/nvim/init.lua
  ln -s $HOME/dotfiles/lua ~/.config/nvim/lua

  echo "New dotfiles created"
}

main(){
  remove_old_dotfiles
  create_sym_lynk
}

chsh -s /bin/zsh

main $!

