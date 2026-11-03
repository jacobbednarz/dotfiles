# turn off the damn greeting
set fish_greeting

# rg
if command -v fzf &>/dev/null && command -v rg &>/dev/null
    set -gx FZF_DEFAULT_COMMAND 'rg --files --no-ignore-vcs --hidden'
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

# Non-interactive shells (scripts, editors, agents) never draw a prompt, so
# they would pay for `hook-env` on startup without benefiting from it. Shims
# resolve the same tool versions per invocation instead.
if command -v mise &>/dev/null
    if status is-interactive
        mise activate fish | source
    else
        mise activate fish --shims | source
    end
end

set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
# `gpgconf --launch` costs ~300ms even when the agent is already running;
# connecting autostarts it just the same for a fraction of the cost.
gpg-connect-agent --quiet /bye >/dev/null

fish_add_path /Users/jacob/go/bin

# global mysql
if test -x "$HOMEBREW_PREFIX/opt/mysql@8.4/bin/mysql"
    fish_add_path "$HOMEBREW_PREFIX/opt/mysql@8.4/bin"
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

# Everything below only matters with a prompt and keybindings, and costs
# non-interactive shells time for nothing.
if status is-interactive
    set -gx GPG_TTY (tty)

    # hub
    if command -v hub &>/dev/null
        eval (hub alias -s)
    end

    # fzf
    if command -v fzf &>/dev/null
        fzf --fish | source
    end

    # smarter `cd`
    if command -v zoxide &>/dev/null
        zoxide init fish | source
    end

    # skip the stub `init` emits, which round-trips the full init through `psub`
    starship init fish --print-full-init | source
end
