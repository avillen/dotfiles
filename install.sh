#!/bin/zsh

# Input
# $1 list of file path
remove_old_dotfiles(){
  local paths="$1"

  echo "Removing old dotfiles"
  rm $HOME/.aliases
  rm -r $HOME/.git
  rm $HOME/.gitignore
  rm -rf $HOME/.vim
  rm $HOME/.vimrc
  rm $HOME/.vimrc.bundles
  rm -r $HOME/.zsh
  rm $HOME/.zshrc
  echo "Dotfiles removed"
}

# Input
# $1 file path
create_sym_lynk(){
  # local path="$1"

  echo "Creating new dotfiles"
  mkdir ~/dotfiles/.vim/bundle
  ln -s ~/dotfiles/.aliases ~/.aliases
  ln -s ~/dotfiles/.git ~/.git
  ln -s ~/dotfiles/.gitignore ~/.gitignore
  ln -s ~/dotfiles/.vim ~/.vim
  ln -s ~/dotfiles/.vimrc ~/.vimrc
  ln -s ~/dotfiles/.vimrc.bundles ~/.vimrc.bundles
  ln -s ~/dotfiles/.zsh ~/.zsh
  ln -s ~/dotfiles/.zshrc ~/.zshrc
  echo "New dotfiles created"
}

search_dot_files(){
  local dotfiles

  dotfiles=$(ls -ld ~/.?*)

  echo "${dotfiles}"
}

main(){
  local dotfiles
  dotfiles=$(search_dot_files)

  remove_old_dotfiles dotfiles
  create_sym_lynk dotfiles
}

chsh -s /bin/zsh

main $!

