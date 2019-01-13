parental [![Build Status](https://travis-ci.org/morulus/parental.bash.svg)](https://travis-ci.org/morulus/parental.bash)
-----

A shortest way to find up a path in the parental directories

## Installation

Execute the following command in your terminal:

```shell
TD=$(mktemp -d) && curl -L https://github.com/morulus/parental.bash/archive/v0.1.5.tar.gz| tar -xz --strip-components=1 -C "$TD" && \
cd $TD && make install && rm -rf $TD
```

> On OS X you'll need to make sure ~/.bashrc is sourced from ~/.bash_profile (http://ss64.com/osx/syntax-bashrc.html).

## Usage

The parental exports short commands:

- `..` (alias of `parental`) to resolve nearest path in the parent directories
- `...` (greedy mode of parental, alias of `parental -g`) to resolve all matches in the parent directories.

Examples:

```bash
# Find closest .npmrc in the parent folders
.. .npmrc
  => /Users/root/.npmrc

# Get list of all .npmrc found on the way to the root folder
... .npmrc
  => /Users/root/project/my-project/.npmrc
  => /Users/root/.npmrc

# Get list of all nearest files started with bash
.. .bash*
/Users/root/.bash_history
/Users/root/.bash_profile
/Users/root/.bash_sessions
/Users/root/.bashrc

# Find package.json, being somewhere depths of a project
.. .package.json
  => /Users/root/projects/some-project/package.json

# Check: are we inside a git repo?
... .git
  => parental: .git not found

# Get the names of all sh scripts, located in the nearest directory .bin
.. .bin/*.sh
  => /Users/root/projects/my-project/.bin/start.sh
  => /Users/root/projects/my-project/.bin/stop.sh
  => /Users/root/projects/my-project/.bin/test.sh

# The same, but with a limited output
.. .bin/*.sh -n 1
  => /Users/root/projects/my-project/.bin/start.sh

# Execute resolved file
`.. .bin/start*`

# Edit resolved file with your favorite IDE
code `.. .bin/start*`

# Turn on the imagination...
```

## Using glob patterns

You can use glob patterns with command `..`

```bash
.. node_modules/babel-*/package.json
```

> But the command `...` (greedy mode) doesn't work with glob patterns correctly by the reason, that pattern expansion takes place before the command is actually run. Because of this trait the program `...` accept already resolved paths and can not know what exactly your pattern really was.

>

## Known limitations and bugs

- Aliases `..` and `...` doesn't work in the subshell scripts. Use `parental` and `parental -g` instead. Any help in solving this problem is welcome.

## License

[MIT](./LICENSE)
