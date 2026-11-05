#!/usr/bin/env bats

load helper

@test "all declared dotfiles deploy with their configured mode and source" {
    apply_dotfiles
    mise_test dot status --json --missing >"$BATS_TEST_TMPDIR/status.json"
    "$TEST_PYTHON" "$DOTFILES_REPO/tests/machine.py" deployment <"$BATS_TEST_TMPDIR/status.json"
    [ -L "$TEST_ROOT/home/tracked-fixture" ]
    cmp "$TEST_ROOT/home/tracked-fixture" "$TEST_CHECKOUT/tracked-fixture"
}

@test "excluded and untracked files stay out of the home directory" {
    apply_dotfiles
    "$TEST_PYTHON" "$DOTFILES_REPO/tests/machine.py" exclusions
}

@test "applying twice leaves the deployment unchanged" {
    apply_dotfiles
    mise_test dot status --json --missing >"$BATS_TEST_TMPDIR/before.json"
    apply_dotfiles
    mise_test dot status --json --missing >"$BATS_TEST_TMPDIR/after.json"
    cmp "$BATS_TEST_TMPDIR/before.json" "$BATS_TEST_TMPDIR/after.json"
}

@test "conflicting files are preserved unless replacement is requested" {
    printf 'keep my changes\n' >"$TEST_ROOT/home/tracked-fixture"
    run ! apply_dotfiles
    [ "$(cat "$TEST_ROOT/home/tracked-fixture")" = 'keep my changes' ]
    mise_test dot apply --force --yes
    mise_test dot status --missing
    cmp "$TEST_ROOT/home/tracked-fixture" "$TEST_CHECKOUT/tracked-fixture"
}

@test "missing deployed files are detected and repaired" {
    apply_dotfiles
    unlink "$TEST_ROOT/home/tracked-fixture"
    run ! mise_test dot status --missing
    apply_dotfiles
    mise_test dot status --missing
    [ -L "$TEST_ROOT/home/tracked-fixture" ]
}

@test "all tracked Fish scripts parse" {
    while IFS= read -r -d '' script; do
        machine fish --no-config --no-execute "$TEST_CHECKOUT/$script"
    done < <(git -C "$TEST_CHECKOUT" ls-files -z '*.fish')
}

@test "deployed Fish configuration starts without errors" {
    apply_dotfiles
    # Fish must expand the variable inside the child shell.
    # shellcheck disable=SC2016
    run -0 machine fish -c 'functions --query reload; or exit 1; test -n "$SSH_AUTH_SOCK"'
    [ -z "$output" ]
}
