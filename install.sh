#!/usr/bin/env bash

set -euo pipefail

DOTFILES_REPO="https://github.com/jacobbednarz/dotfiles.git"
DEFAULT_DOTFILES_PATH="${HOME}/src/dotfiles"
SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [ -d "${SCRIPT_DIR}/.git" ]; then
  DOTFILES_PATH="${DOTFILES_PATH:-${SCRIPT_DIR}}"
else
  DOTFILES_PATH="${DOTFILES_PATH:-${DEFAULT_DOTFILES_PATH}}"
fi

info() {
  printf 'info: %s\n' "$1"
}

fail() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

OS="$(uname -s 2>/dev/null)"
if [ "${OS}" != "Darwin" ] && [ "${OS}" != "Linux" ]; then
  fail "this installer only works on macOS and Linux"
fi

export PATH="${HOME}/.local/bin:/opt/homebrew/bin:/usr/local/bin:/home/linuxbrew/.linuxbrew/bin:${PATH}"

if ! command -v git >/dev/null 2>&1; then
  fail "git is not installed, please install it first"
fi

if ! command -v curl >/dev/null 2>&1; then
  fail "curl is not installed, please install it first"
fi

if [ ! -d "${DOTFILES_PATH}" ]; then
  info "cloning dotfiles"
  mkdir -p "$(dirname -- "${DOTFILES_PATH}")"
  git clone "${DOTFILES_REPO}" "${DOTFILES_PATH}"
fi

if ! command -v mise >/dev/null 2>&1; then
  info "installing mise"
  curl -fsSL https://mise.run | sh
  export PATH="${HOME}/.local/bin:${PATH}"
fi

info "trusting mise config"
mise trust --quiet --yes --cd "${DOTFILES_PATH}"

info "running mise bootstrap"
mise bootstrap --yes --cd "${DOTFILES_PATH}" "$@"
