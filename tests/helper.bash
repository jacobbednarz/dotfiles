setup() {
    bats_require_minimum_version 1.5.0
    export DOTFILES_REPO
    DOTFILES_REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
    export TEST_PYTHON TEST_MISE
    TEST_PYTHON="$(command -v python3)"
    TEST_MISE="$(command -v mise)"
    export TEST_ROOT="$BATS_TEST_TMPDIR/machine"
    export TEST_CHECKOUT
    TEST_CHECKOUT="$("$TEST_PYTHON" "$DOTFILES_REPO/tests/machine.py" prepare)"
}

machine() {
    env -i \
        HOME="$TEST_ROOT/home" \
        PATH="$(dirname "$TEST_MISE"):/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
        TERM=dumb \
        GNUPGHOME="$TEST_ROOT/home/.gnupg" \
        XDG_CONFIG_HOME="$TEST_ROOT/home/.config" \
        XDG_DATA_HOME="$TEST_ROOT/data" \
        XDG_CACHE_HOME="$TEST_ROOT/cache" \
        XDG_STATE_HOME="$TEST_ROOT/state" \
        MISE_SELF_UPDATE_AUTO=false \
        MISE_GLOBAL_CONFIG_FILE="$TEST_CHECKOUT/mise.toml" \
        MISE_GLOBAL_CONFIG_ROOT="$TEST_CHECKOUT" \
        MISE_TRUSTED_CONFIG_PATHS="$TEST_CHECKOUT" \
        MISE_YES=1 \
        "$@"
}

mise_test() {
    machine "$TEST_MISE" --cd "$TEST_CHECKOUT" "$@"
}

apply_dotfiles() {
    mise_test bootstrap --only dotfiles --yes
}

teardown() {
    if [ -d "$TEST_ROOT/home/.gnupg" ]; then
        machine gpgconf --kill gpg-agent
    fi
}
