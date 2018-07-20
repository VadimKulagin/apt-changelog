# apt-changelog

The script for visualizing the list of changes to apt packages that need to be updated.

The script displays only those changes that differ from the installed versions of packages in the form of a single list with delimiters.

The list of packages is taken from the output of `apt list --upgradable`.


## Usage

```bash
./changelog.sh [-d] [-l] [PACKAGE]...
```

If you have packages waiting for updates and want to find out what they have changed, then simply run the script.

### Display the changelog as a single list for all packages

```bash
./changelog.sh
```

You will see something like this:

```
netplan.io/bionic-updates 0.36.3 amd64 [upgradable from: 0.36.2]
Description: YAML network configuration abstraction for various backends
Current version: 0.36.2
netplan.io (0.36.3) bionic; urgency=medium

  * Generate udev rules files to rename devices (LP: #1770082)
  * tests/integration.py: fix test_eth_and_bridge autopkg test harder.
  * tests/integration.py: fix test_mix_bridge_on_bond autopkgtest too.

=====================================================

squashfs-tools/bionic-updates 1:4.3-6ubuntu0.18.04.1 amd64 [upgradable from: 1:4.3-6]
Description: Tool to create and append to squashfs filesystems
Current version: 1:4.3-6
squashfs-tools (1:4.3-6ubuntu0.18.04.1) bionic; urgency=medium

  * debian/patches/0010-use-macros-not-raw-octal-with-chmod.patch,

=====================================================
```

### Display the changelog for specific packages

```bash
./changelog.sh netplan.io squashfs-tools
```

### Display the changelog with the `less` for each individual package

```bash
./changelog.sh -l
```


## Options

Option  | Description
--------|-------------
-d      | Do not show a description for each package (can increase performance)
-l      | Use `less` to display the changelog of each package
PACKAGE | A package name. Can be specified several names separated by a space


## Compatibility

The script was tested on:

- Ubuntu 18.04 (bionic)
- Debian 9.5 (stretch)


## Caveats

The script displays the information in a human readable form. 
It is not intended to be displayed in a machine-readable form, so the output format may change with time.


## License

[MIT](https://github.com/VadimKulagin/apt-changelog/blob/master/LICENSE)
