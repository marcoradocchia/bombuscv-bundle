#!/bin/bash

# Colored output.
RED="\e[1;31m"
YELLOW="\e[1;33m"
GREEN="\e[1;32m"
CYAN="\e[1;36m"
NORM="\e[0m"

# Installation path.
BIN_DIR=$HOME/.local/bin

# Print error message and exit.
exit_msg() {
  printf $RED"==> Error:$NORM $1.\n"
  exit 1
}

# Check dependencies.
install_deps() {
  # Install raspi-config to enable I2C interface later.
  sudo apt-get install git raspi-config
  # If cargo isn't a command, install rustup.
  command -v cargo > /dev/null || {
    printf "$GREEN==> Installing rustup...$NORM\n"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  }
  # Can't install systemd if not already present: unrecoverable error.
  command -v systemctl > /dev/null || exit_msg "systemd required in order to use this software"
}

# Install `datalogger` + `bombuscv-display`
install_datalogger_display() {
  # Check if ~/.local/bin dir exists and it's in PATH.
  [ -d $BIN_DIR ] || mkdir -p $BIN_DIR
  echo $PATH | grep $HOME/.local/bin > /dev/null \
    || exit_msg "please add \$HOME/.local/bin to PATH"

  # Enable I2C interface with raspi-config in non-interactive mode.
  printf $GREEN"==> Enabling I2C interface...\n"
  sudo raspi-config nonint do_i2c 0

  printf $GREEN"==> Installing bombuscv-display...\n"
  # Clone `bombuscv-display` repository and compile with `release` flag.
  [ -d bombuscv-display ] || git clone https://github.com/marcoradocchia/bombuscv-display
  cd bombuscv-display
  cargo build --release
  # Install `bombuscv-display` to ~/.local/bin.
  install -Dm755 ./target/release/bombuscv-display -t $BIN_DIR
  cd ..
  rm -rf bombuscv-display

  printf $GREEN"==> Installing datalogger...\n"
  # Clone `datalogger` repository and compile with `release` flag.
  [ -d datalogger ] || git clone https://github.com/marcoradocchia/datalogger
  cd datalogger
  cargo build --release
  # Install `datalogger` to ~/.local/bin.
  install -Dm755 ./target/release/datalogger -t $BIN_DIR
  cd ..
  rm -rf datalogger

  # Install systemd service for datalogger and display.
  sudo install -Dm644 ./bombuscv-display.service -t /etc/systemd/system/
  # Enable the service for boot startup.
  sudo systemctl enable bombuscv-display.service
}

# Install `bombuscv-rs`.
install_bombuscv() {
  printf $GREEN"==> Installing bombuscv-rs...\n"

  curl \
    --proto '=https' \
    --tlsv1.2 \
    -sSf https://raw.githubusercontent.com/marcoradocchia/bombuscv-rs/master/bombuscv-raspi.sh \
    | sh -- -m -u
}

# Print greeting message.
greet() {
  printf "$CYAN\n\n############################\n"
  printf          "## Installation complete! ##\n"
  printf          "############################\n$NORM"
}

printf "$YELLOW██████╗  ██████╗ ███╗   ███╗██████╗ ██╗   ██╗███████╗ ██████╗██╗   ██╗\n"
printf        "██╔══██╗██╔═══██╗████╗ ████║██╔══██╗██║   ██║██╔════╝██╔════╝██║   ██║\n"
printf   "$NORM██████╔╝██║   ██║██╔████╔██║██████╔╝██║   ██║███████╗██║     ██║   ██║\n"
printf        "██╔══██╗██║   ██║██║╚██╔╝██║██╔══██╗██║   ██║╚════██║██║     ╚██╗ ██╔╝\n"
printf "$YELLOW██████╔╝╚██████╔╝██║ ╚═╝ ██║██████╔╝╚██████╔╝███████║╚██████╗ ╚████╔╝ \n"
printf        "╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚═════╝  ╚═════╝ ╚══════╝ ╚═════╝  ╚═══╝  $NORM\n"
printf "$YELLOW        ██████╗ ██╗   ██╗███╗   ██╗██████╗ ██╗     ███████╗\n"
printf        "        ██╔══██╗██║   ██║████╗  ██║██╔══██╗██║     ██╔════╝\n"
printf   "$NORM        ██████╔╝██║   ██║██╔██╗ ██║██║  ██║██║     █████╗  \n"
printf        "        ██╔══██╗██║   ██║██║╚██╗██║██║  ██║██║     ██╔══╝  \n"
printf "$YELLOW        ██████╔╝╚██████╔╝██║ ╚████║██████╔╝███████╗███████╗\n"
printf        "        ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚══════╝╚══════╝$NORM\n\n"

printf "$CYAN#############################################################################\n"
printf      "## Installation helper script for the bombuscv bundle (by Marco Radocchia) ##\n"
printf      "## Requirement:                                                            ##\n"
printf      "##   - datalogger + bombuscv-display: generic Linux RaspberryPi            ##\n"
printf      "##   - bombuscv-rs: RaspberryPi 4 (4/8GB) with RaspberryPi OS aarch64      ##\n"
printf      "## Warning: the installation process may take a while                      ##\n"
printf      "#############################################################################\n\n$NORM"

# Check if Raspberry Pi is running RaspberryPi OS 64 bits:
[ $(uname -m) != "aarch64" -o $(command -v apt-get | wc -l) != 1 ] && \
  exit_msg "please install RaspberryPi OS 64 bits and retry"

# Check if Raspberry is at least 4GB RAM.
[ $(free --mebi | grep -e "^Mem:" | awk '{print $2}') -lt 3000 ] && \
  exit_msg "required at least 4GB of RAM"

# Install updates & check dependencies.
printf "$GREEN==> Updating the system & install dependencies...$NORM\n"
sudo apt-get update && sudo apt-get upgrade
install_deps

# User selection.
printf $GREEN"Please select desierd option:\n"$NORM
printf "  1) bombusv-rs\n"
printf "  2) datalogger + bombuscv-display\n"
printf "  3) complete bundle (bombusv-rs + datalogger + bombuscv-display)\n"
printf $GREEN"==> "$NORM

read selection # Read standard input.
printf "\n"
case $selection in
  1) # Install `bombuscv-rs`.
    install_bombuscv
    break
    ;;
  2) # Install `datalogger` + `bombuscv-display`.
    install_datalogger_display
    break
    ;;
  3) # Install `bombuscv-rs` + `datalogger` + `bombuscv-display`.
    install_bombuscv
    install_datalogger_display
    break
    ;;
  *) # Invalid option.
    printf $RED"invalid option:$NORM exiting...\n"
    exit 1
    ;;
esac && greet
