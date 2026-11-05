"""Build disposable machines and check mise's resolved deployment against disk."""

import json
import os
import shutil
import subprocess
import sys
import tomllib
from pathlib import Path


def prepare():
    repo = Path(os.environ["DOTFILES_REPO"])
    config = tomllib.loads((repo / "mise.toml").read_text())
    root = config["settings"]["dotfiles"]["root"]
    assert root.startswith("~/"), "dotfiles.root must be relative to the test home"
    checkout = Path(os.environ["TEST_ROOT"]) / "home" / root[2:]
    checkout.mkdir(parents=True)
    tracked = subprocess.check_output(
        ["git", "-C", str(repo), "ls-files", "-z"], text=True
    ).split("\0")
    for name in filter(None, tracked):
        source = repo / name
        if source.is_file():
            target = checkout / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
    # The temporary index preserves manifest=git without reading ignored credentials.
    (checkout / "tests").mkdir(exist_ok=True)
    (checkout / "tests/tracked-fixture").write_text("must not deploy\n")
    (checkout / "tracked-fixture").write_text("must deploy\n")
    subprocess.run(["git", "init", "-q", str(checkout)], check=True)
    subprocess.run(["git", "-C", str(checkout), "add", "--force", "."], check=True)
    (checkout / "untracked-fixture").write_text("must not deploy\n")
    print(checkout)


def deployment():
    status = json.load(sys.stdin)
    files = status["files"]
    assert files, "mise resolved no dotfiles"
    home = Path(os.environ["TEST_ROOT"]) / "home"

    def target_path(entry):
        return Path(entry["target"].replace("~", str(home), 1))

    for entry in files:
        assert entry["state"] == "applied", entry
        target = target_path(entry)
        source = Path(entry["origin"]["source"])
        if entry["mode"] == "symlink":
            assert target.is_symlink(), entry
            assert target.resolve() == source.resolve(), entry
        elif entry["mode"] == "copy":
            assert not target.is_symlink(), entry
            assert target.read_bytes() == source.read_bytes(), entry
        elif entry["mode"] == "symlink-each":
            overrides = [target_path(other) for other in files if other != entry]
            for directory, directories, names in os.walk(target):
                directory = Path(directory)
                directories[:] = [
                    name
                    for name in directories
                    if (directory / name).resolve() != source.resolve()
                ]
                for name in directories + names:
                    deployed = directory / name
                    if deployed.is_symlink() and deployed not in overrides:
                        expected = source / deployed.relative_to(target)
                        assert deployed.exists(), deployed
                        assert deployed.resolve() == expected.resolve(), deployed
        else:
            raise AssertionError(f"Add a filesystem assertion for mode: {entry}")


def exclusions():
    checkout = Path(os.environ["TEST_CHECKOUT"])
    home = Path(os.environ["TEST_ROOT"]) / "home"
    config = tomllib.loads((checkout / "mise.toml").read_text())
    for group in config["dotfile_groups"].values():
        for pattern in group.get("exclude", []):
            for source in checkout.glob(pattern):
                target = home / source.relative_to(checkout)
                assert not target.exists() and not target.is_symlink(), target
    assert not (home / "untracked-fixture").exists()


if __name__ == "__main__":
    {"prepare": prepare, "deployment": deployment, "exclusions": exclusions}[
        sys.argv[1]
    ]()
