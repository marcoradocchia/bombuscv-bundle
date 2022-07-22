<div align="center">
  <h1 align="center">BombusCV Bundle</h1>
</div>

BombusCV complete package and installation scripts for **Raspberry Pi**.

This repository contains the full installation scripts to setup a **BombusCV
device**[^1]. The installation script provides:

- [`bombuscv-rs`](https://github.com/marcoradocchia/bombuscv-rs)[^2];
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

[^1]: Raspberry Pi 4 (4GB of RAM) with Raspberry Pi camera, DHT22 humidity &
  temperature sensor and SSD1306, 0.96" (128x64), I2C display
[^2]: Requires Raspberry Pi 4 with at least 4GB of RAM, running Raspberry Pi OS
  aarch64

## Usage

In order to install the **BombusCV Bundle** on **Raspberry Pi**, clone this
repository and execute `install.sh` script:
```sh
git clone https://github.com/marcoradocchia/bombuscv-bundle.git
cd bombuscv-bundle
./install.sh
```
