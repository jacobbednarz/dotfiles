# turn off the damn greeting
set fish_greeting

# hub
if command -v hub &>/dev/null
    eval (hub alias -s)
end

# rg
if command -v fzf &>/dev/null && command -v rg &>/dev/null
    set -gx FZF_DEFAULT_COMMAND 'rg --files --no-ignore-vcs --hidden'
end

# fzf
if command -v fzf &>/dev/null
    fzf --fish | source
end

# source homebrew-compatible packages
set -l homebrew_prefix /opt/homebrew
if test (uname -s) = Linux
    set homebrew_prefix /home/linuxbrew/.linuxbrew
end

if test -d "$homebrew_prefix"
    set -gx HOMEBREW_PREFIX "$homebrew_prefix"
    fish_add_path "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin"
end

fish_add_path "$HOME/.local/bin"

set -gx HOMEBREW_NO_ENV_HINTS 1

if command -v mise &>/dev/null
    mise activate fish | source
end

set -gx GPG_TTY (tty)
set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

fish_add_path /Users/jacob/go/bin

# global mysql
if test -x "$HOMEBREW_PREFIX/opt/mysql@8.4/bin/mysql"
    fish_add_path "$HOMEBREW_PREFIX/opt/mysql@8.4/bin"
end

# smarter `cd`
if command -v zoxide &>/dev/null
    zoxide init fish | source
end

# add grit tooling to the $PATH
if command -v grit &>/dev/null
    fish_add_path "$HOME/.grit/bin"
end

# proto
if command -v proto &>/dev/null
    set -gx PROTO_HOME "$HOME/.proto"

    fish_add_path "$PROTO_HOME/shims"
    fish_add_path "$PROTO_HOME/bin"
end

# gcloud utils
if command -v gcloud &>/dev/null
    fish_add_path "$HOMEBREW_PREFIX/share/google-cloud-sdk/bin"
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

starship init fish | source
