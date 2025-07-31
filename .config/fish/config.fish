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

# source homebrew
eval (/opt/homebrew/bin/brew shellenv)

set -gx GPG_TTY (tty)
set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

fish_add_path "/Users/jacob.bednarz/.dotnet/tools"
fish_add_path "/Users/jacob.bednarz/.local/bin" # python and other tools that use XDG

# smarter `cd`
if command -v zoxide &>/dev/null
    zoxide init fish | source
end

function fish_prompt
    set -l last_pipestatus $pipestatus
    set -l normal (set_color normal)

    # Color the prompt differently when we're root
    set -l color_cwd $fish_color_cwd
    set -l prefix
    set -l suffix '$'

    if contains -- $USER root toor
        if set -q fish_color_cwd_root
            set color_cwd $fish_color_cwd_root
        end
        set suffix '#'
    end

    # If we're running via SSH, change the host color.
    set -l color_host $fish_color_host
    if set -q SSH_TTY
        set color_host $fish_color_host_remote
    end

    # Write pipestatus
    set -l prompt_status (__fish_print_pipestatus " [" "]" "|" (set_color $fish_color_status) (set_color --bold $fish_color_status) $last_pipestatus)

    echo -n -s (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal $prompt_status $suffix " "
end

function reload
    if test (count $argv) -eq 0
        _reload_shell
    else
        switch $argv[1]
            case all
                _reload_shell
                _reload_direnv
            case yubikey
                _reload_yubikey
            case direnv
                _reload_direnv
            case '*'
                _reload_shell
        end
    end
end

function _reload_shell
    source ~/.config/fish/config.fish

    echo config reloaded
end

function _reload_direnv
    direnv allow

    echo direnv reloaded
end

function _reload_yubikey
    rm -r ~/.gnupg/private-keys-v1.d
    gpgconf --kill gpg-agent
    killall gpg-agent
    gpg-agent --daemon
end

function jwt
    ruby -rjson -rbase64 -rzlib -rstringio -e "ARGV[0].split('.')[0,2].each_with_index { |f, i| begin; j = JSON.parse(Base64.urlsafe_decode64(f)); rescue JSON::ParserError; j = JSON.parse(Zlib::GzipReader.new(StringIO.new(Base64.urlsafe_decode64(f))).read); end; jj j; break if i.zero? && j.key?('enc')}" $argv[1]
end
