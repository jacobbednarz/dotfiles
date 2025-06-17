#!/usr/bin/env bash

DOTFILES_REPO="https://github.com/jacobbednarz/dotfiles.git"
DOTFILES_PATH="${HOME}/src/dotfiles"

reset="$(tput sgr0)"
highlight="$(tput smso)"
dim="$(tput dim)"
red="$(tput setaf 1)"
blue="$(tput setaf 4)"
green="$(tput setaf 2)"
yellow="$(tput setaf 3)"
bold=$(tput bold)
normal=$(tput sgr0)
underline="$(tput smul)"

trap 'ret=$?; test $ret -ne 0 && printf "${red}setup failed${reset}n" >&2; exit $ret' EXIT
set -e

print_success() {
  printf "${green}✔ success:${reset} %b\n" "$1"
}

print_error() {
  printf "${red}✖ error:${reset} %b\n" "$1"
}

print_info() {
  printf "${blue}ⓘ info:${reset} %b\n" "$1"
}

indent() {
  sed "s/^/  /"
}

OS=$(uname -s 2>/dev/null)
if [ "${OS}" != "Darwin" ]; then
  print_error "this installer only works on MacOS"
  exit 1
fi

print_info "checking if ~/src exists"
if [ ! -d "${HOME}/src" ]; then
  print_info "creating ~/src"
  mkdir -p $HOME/src
else
  print_success "~/src exists"
fi

if [ ! -d "$DOTFILES_PATH" ]; then
  print_info "cloning dotfiles"
  git clone ${DOTFILES_REPO} ${DOTFILES_PATH}
else
  print_info "dotfiles already cloned"
fi

print_info "checking if homebrew is installed"
if [ ! -d "/opt/homebrew" ]; then
  print_info "installing homebrew"
  curl -fsS 'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby
  eval $(/opt/homebrew/bin/brew shellenv)
  print_success "homebrew is installed"
else
  eval $(/opt/homebrew/bin/brew shellenv)
  print_info "homebrew already installed"
fi

print_info "checking if stow is installed"
if ! [ -x "$(command -v stow)" ]; then
  brew install stow
else
  print_info "stow already installed"
fi

print_info "checking if fish is installed"
if ! [ -x "$(command -v fish)" ]; then
  brew install fish
else
  print_info "fish already installed"
fi

print_info "checking fish is an available shell"
if ! grep -q fish /etc/shells; then
  command -v fish | sudo tee -a /etc/shells
  print_success "fish added to available shells"
else
  print_info "fish is an available shell"
fi

if [ "$SHELL" != "/opt/homebrew/bin/fish" ]; then
  print_info "updating default shell for $USER"
  chsh -s $(which fish)
  print_success "default shell updated"
else
  print_info "fish is already the default shell"
fi

print_info "linking dotfiles"
stow . --dir="$HOME/src/dotfiles" --target="$HOME"
print_success "dotfiles installed"

print_info "running brew bundle check"
if [ -f "$HOME/.Brewfile" ]; then
  brew bundle check --global >/dev/null 2>&1 || {
    brew bundle install --global --cleanup | indent
  }
else
  print_info "Brewfile not found, skipping"
fi

print_success "installer complete"
