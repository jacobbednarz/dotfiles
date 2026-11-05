# dotfiles

Everything is set up by [mise bootstrap](https://mise.jdx.dev/bootstrap.html)
from `mise.toml`: packages, tools, macOS defaults and the dotfiles themselves.
Every file git tracks here is symlinked to the same path under `~`.

## Setting up a new machine

Plug in the YubiKey first. Once the dotfiles are linked, GitHub fetches go over
SSH through gpg-agent, so expect a PIN prompt partway through.

```sh
curl https://mise.run | sh
~/.local/bin/mise bootstrap --yes --from https://github.com/jacobbednarz/dotfiles.git --from-dir ~/src/dotfiles
```

Then sign in to the GitHub CLI with `gh auth login`.

## Applying changes

```fish
mise dot apply
```

New files are only linked once they are added to git.

## Testing

Install [Bats](https://bats-core.readthedocs.io/), Fish, GnuPG and Python 3.11+
to run the same deployment tests as CI:

```fish
brew install bats-core fish gnupg python
bats --print-output-on-failure tests
```

Each test copies the current contents of tracked files into a temporary Git
checkout and applies the real configuration in an isolated home directory.
Ignored credentials are never copied. New dotfiles need to be tracked before
these tests exercise them, just as they do for deployment.

Assertions use mise's resolved configuration and status, then check symlink
targets and copied contents on disk. Exclusions come from `mise.toml`. Repeated
applies and Fish startup are checked separately. Adding packages, tools or
dotfiles does not require maintaining another list in the tests.

The **CI** workflow also has an optional **install** input. Enable it when
running the workflow manually to install every package and tool declared in
`mise.toml`, then check `mise bootstrap packages status --missing` and
`mise ls --current --missing`. This job runs on a disposable macOS runner:
Homebrew changes are machine-wide, so it is deliberately disabled locally.
Large casks, upstream availability and tool builds can make this job slow.

The suite does not exercise desktop application UIs, login-shell changes,
macOS preferences, LaunchAgent supervision or physical YubiKey authentication.
