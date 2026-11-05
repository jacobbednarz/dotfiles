#!/usr/bin/env bats

load helper

@test "declared packages and tools install on macOS" {
    if [ "${DOTFILES_TEST_INSTALL:-0}" != 1 ]; then
        skip "enable the workflow's install input to exercise all packages and tools"
    fi
    [ "${GITHUB_ACTIONS:-false}" = true ]
    [ "$(uname -s)" = Darwin ]

    mise_test bootstrap --only packages,tools --yes
    mise_test bootstrap packages status --missing
    mise_test ls --current --missing --json >"$BATS_TEST_TMPDIR/missing.json"
    "$TEST_PYTHON" -c 'import json, sys; missing = json.load(sys.stdin); assert not missing, missing' <"$BATS_TEST_TMPDIR/missing.json"
}
