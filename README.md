# dotfiles

Because everyone needs some dotfiles.

## Installation

While this is _pretty_ specific to how I like my machine to be setup, this can
be setup on any machine but your mileage may vary.

```
$ git clone git@github.com:jacobbednarz/dotfiles.git
$ cd dotfiles
$ script/bootstrap
```

The install script will symlink the appropriate files in `dotfiles` to your
home directory. Everything is configured and tweaked within `~/dotfiles`,
though. All files and folders ending in `.symlink` get, you guessed it,
symlinked. For example: `~/dotfiles/vim/vimrc.symlink` gets symlinked to
`~/.vimrc`.

## Topical

Everything's built around topic areas. If you're adding a new area to your
forked dotfiles — say, "Java" — you can simply add a java directory and put
files in there. Anything with an extension of `.symlink` will get symlinked
without extension into `$HOME` when you run `script/bootstrap`.

## The magic

There's a few special files in the hierarchy.

- `bin/*`: Anything in `bin/` will get added to `/usr/local/bin` and be made
  available everywhere.
- `<topic>/*.symlink`: Any files ending in `*.symlink` get symlinked into
  your `$HOME`. This is so you can keep all of those versioned in your dotfiles
  but still keep those autoloaded files in your home directory. These get
  symlinked in when you run `script/bootstrap`.
- `<topic>/install.sh`: The 'installer' files inside of a directory will be 
  automatically sourced and ran. This pattern is useful if you need to run 
  additional scripts or tasks for a topic.

## What's inside

- Detailed settings for ack, wget, curl
- A bin directory with many handy scripts and shortcuts
- Git settings
- Homebrew packages and install script
- A script to install all my favourite OSX defaults
- Ruby setting files for chruby, irb, gems and rspec
- Setup script to symlink and add paths to your `$PATH` (invoke using `script/bootstrap`)
- Tmux configurations and tmux-powerline configurations
- Vim setings and must have plugins
- Zsh configurations
- Sublime user preferences and themes

## Thanks!
[@holman](https://github.com/holman) and [@pengwynn](https://github.com/pengwynn) for a handful of scripts and goodness.
