#!/usr/bin/env bash

DOTFILES_REPO="https://github.com/jacobbednarz/dotfiles.git"
DOTFILES_PATH="${HOME}/src/dotfiles"

# don't use tput if we don't have a terminal...like in CI 😢
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && tput setaf 1 >/dev/null 2>&1; then
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
else
  reset=""
  highlight=""
  dim=""
  red=""
  blue=""
  green=""
  yellow=""
  bold=""
  normal=""
  underline=""
fi

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
if [ "${OS}" != "Darwin" ] && [ "${OS}" != "Linux" ]; then
  print_error "this installer only works on MacOS and Linux"
  exit 1
fi

print_info "checking if $HOME/src exists"
if [ ! -d "${HOME}/src" ]; then
  print_info "creating $HOME/src"
  mkdir -p "$HOME/src"
else
  print_success "$HOME/src exists"
fi

if [ ! -d "$DOTFILES_PATH" ]; then
  print_info "cloning dotfiles"
  git clone "${DOTFILES_REPO}" "${DOTFILES_PATH}"
else
  print_info "dotfiles already cloned"
fi

print_info "checking if homebrew is installed"
if ! command -v brew >/dev/null 2>&1; then
  print_info "installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  print_success "homebrew is installed"
else
  # shellcheck disable=SC2046
  eval $(brew shellenv)
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
FISH_PATH="$(command -v fish)"
if ! grep -q "^${FISH_PATH}$" /etc/shells; then
  echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
  print_success "fish added to available shells"
else
  print_info "fish is an available shell"
fi

if [ -z "$CI" ]; then
  if [ "$SHELL" != "$FISH_PATH" ]; then
    print_info "updating default shell for $USER"
    chsh -s "$FISH_PATH"
    print_success "default shell updated"
  else
    print_info "fish is already the default shell"
  fi
else
  print_info "skipping shell adjustment as we are running in CI"
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
