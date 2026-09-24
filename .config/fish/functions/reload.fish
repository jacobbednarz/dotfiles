function reload
    if test (count $argv) -eq 0
        _reload_shell
    else
        switch $argv[1]
            case all
                _reload_shell
            case yubikey
                _reload_yubikey
            case '*'
                _reload_shell
        end
    end
end

function _reload_shell
    source ~/.config/fish/config.fish
    echo "config reloaded"
end

function _reload_yubikey
    rm -r ~/.gnupg/private-keys-v1.d
    gpgconf --kill gpg-agent
    killall gpg-agent
    gpg-agent --daemon
end
