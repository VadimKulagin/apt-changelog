# apt-changelog

The script for visualizing the list of changes to apt packages that need to be updated.

The script displays only those changes that differ from the installed versions of packages in the form of a single list with delimiters.

The list of packages is taken from the output of `apt list --upgradable`.


## Usage

If you have packages waiting for updates and want to find out what they have changed, then simply run the script.

### Display the changelog as a single list for all packages

```bash
./changelog.sh
```

You will see something like this:

```
netplan.io/bionic-updates 0.36.3 amd64 [upgradable from: 0.36.2]
Current version: 0.36.2
netplan.io (0.36.3) bionic; urgency=medium

  * Generate udev rules files to rename devices (LP: #1770082)
  * tests/integration.py: fix test_eth_and_bridge autopkg test harder.
  * tests/integration.py: fix test_mix_bridge_on_bond autopkgtest too.

netplan.io (0.36.2) bionic; urgency=medium

=====================================================

squashfs-tools/bionic-updates 1:4.3-6ubuntu0.18.04.1 amd64 [upgradable from: 1:4.3-6]
Current version: 1:4.3-6
squashfs-tools (1:4.3-6ubuntu0.18.04.1) bionic; urgency=medium

  * debian/patches/0010-use-macros-not-raw-octal-with-chmod.patch,

squashfs-tools (1:4.3-6) unstable; urgency=medium

=====================================================
```

### Display the changelog with the `less` for each individual package

```bash
./changelog.sh -l
```


## Compatibility

The script was tested on:

- Ubuntu 18.04 (bionic)
- Debian 9.5 (stretch)


## Caveats

The script displays the information in a human readable form. 
It is not intended to be displayed in a machine-readable form, so the output format may change with time.


## License

[MIT](https://github.com/VadimKulagin/apt-changelog/blob/master/LICENSE)
