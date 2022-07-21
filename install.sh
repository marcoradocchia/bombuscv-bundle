#!/usr/bin/env sh

BIN_DIR=$HOME/.local/bin

# Check build dependencies
exit_msg() {
  echo $1
  exit 1
}

command -v git > /dev/null || exit_msg "error: please install git and retry"
command -v cargo > /dev/null || exit_msg "error: please install rustup and retry"

# Check if ~/.local/bin dir exists and it's in PATH.
[ -d $BIN_DIR ] || mkdir -p $BIN_DIR
echo $PATH | grep $HOME/.local/bin > /dev/null || echo "error: please add \$HOME/.local/bin to PATH"

# Clone `bombuscv-display` repository and compile with `release` flag.
[ -d bombuscv-display ] || git clone https://github.com/marcoradocchia/bombuscv-display
cd bombuscv-display
cargo build --release
# Install `bombuscv-display` to ~/.local/bin.
install -Dm755 ./target/release/bombuscv-display -t $BIN_DIR
cd ..
rm -rf bombuscv-display

# Clone `datalogger` repository and compile with `release` flag.
[ -d datalogger ] || git clone https://github.com/marcoradocchia/datalogger
cd datalogger
cargo build --release
# Install `datalogger` to ~/.local/bin.
install -Dm755 ./target/release/datalogger -t $BIN_DIR
cd ..
rm -rf datalogger

# Install systemd service for datalogger and display.
# install -Dm644 bombuscv-display.service -t /etc/systemd/system/
