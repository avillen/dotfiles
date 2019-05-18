#!/bin/zsh

remove_old_dotfiles(){
  echo "Removing old dotfiles"

  rm $HOME/.aliases
  rm $HOME/.gitignore
  rm $HOME/.tmux.conf
  rm $HOME/.vimrc
  rm $HOME/.vimrc.bundles
  rm $HOME/.zshrc
  rm -rf $HOME/.zsh
  rm -rf $HOME/.git
  rm -rf $HOME/.vim

  echo "Dotfiles removed"
}

create_sym_lynk(){
  echo "Creating new dotfiles"

  mkdir $HOME/dotfiles/.vim/bundle

  ln -s $HOME/dotfiles/.aliases ~/.aliases
  ln -s $HOME/dotfiles/.gitignore ~/.gitignore
  ln -s $HOME/dotfiles/.tmux.conf ~/.tmux.conf
  ln -s $HOME/dotfiles/.vim ~/.vim
  ln -s $HOME/dotfiles/.vimrc ~/.vimrc
  ln -s $HOME/dotfiles/.vimrc.bundles ~/.vimrc.bundles
  ln -s $HOME/dotfiles/.zsh ~/.zsh
  ln -s $HOME/dotfiles/.zshrc ~/.zshrc

  echo "New dotfiles created"
}

main(){
  remove_old_dotfiles
  create_sym_lynk
}

chsh -s /bin/zsh

main $!

