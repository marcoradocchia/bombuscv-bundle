<div align="center">
  <h1 align="center">BombusCV Bundle</h1>
</div>

BombusCV complete package and installation scripts.

This repository contains the full installation scripts to setup a **BombusCV
device**. The installation script provides:

- [`bombuscv-rs`](https://github.com/marcoradocchia/bombuscv-rs)[^1];
- [`datalogger`](https://github.com/marcoradocchia/datalogger);
- [`bombuscv-display`](https://github.com/marcoradocchia/bombuscv-display).

  However it lets the user choose wheter to install:

- `bombuscv-rs`;
- `datalogger` + `bombuscv-display`;
- `bombuscv-rs` + `datalogger` + `bombuscv-display` (complete bundle).

In order to run `bombuscv-rs` and `bobmuscv-display`, the script will enable
**Legacy camera support** and **I2C interface** respectively, using the
`raspi-config` script.

The script will pull all the dependencies needed, so it can be run on a plain
installation of Raspberry Pi OS.

[^1]: Requires Raspberry Pi 4 with at least 4GB of RAM, running Raspberry Pi OS aarch64.
