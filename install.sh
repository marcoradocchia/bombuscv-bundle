#!/usr/bin/env sh

# TODO: need to enable i2c on raspberry pi to make bombuscv-display work

# Colored output.
RED="\e[1;31m"
YELLOW="\e[1;33m"
GREEN="\e[1;32m"
CYAN="\e[1;36m"
NORM="\e[0m"

# Installation path.
BIN_DIR=$HOME/.local/bin

# Check build dependencies
exit_msg() {
  printf $RED"==> Error:$NORM $1.\n"
  exit 1
}

# Check dependencies.
check_deps() {
  command -v git > /dev/null || exit_msg  "please install git and retry"
  command -v cargo > /dev/null || exit_msg "please install rustup and retry"
  command -v systemctl > /dev/null || exit_msg "systemd required in order to use this software"
}

# Install `datalogger` + `bombuscv-display`
install_datalogger_display() {
  # Check if ~/.local/bin dir exists and it's in PATH.
  [ -d $BIN_DIR ] || mkdir -p $BIN_DIR
  echo $PATH | grep $HOME/.local/bin > /dev/null || exit_msg "please add \$HOME/.local/bin to PATH"

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
  install -Dm644 ./bombuscv-display.service -t /etc/systemd/system/
  # Enable the service for boot startup.
  sudo systemctl enable bombuscv-display.service
}

install_bombuscv() {
  curl \
    --proto '=https' \
    --tlsv1.2 \
    -sSf https://raw.githubusercontent.com/marcoradocchia/bombuscv-rs/master/bombuscv-raspi.sh \
    | sh
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

# Check dependencies.
check_deps

# User selection.
printf $GREEN"Please select desierd option:\n"$NORM
printf "  1) bombusv-rs\n"
printf "  2) datalogger + bombuscv-display\n"
printf "  3) complete bundle (bombusv-rs + datalogger + bombuscv-display)\n"
printf $GREEN"==> "$NORM

case $(read sel) in
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
esac

# Greeting message.
printf
printf "$CYAN############################\n"
printf      "## Installation complete! ##\n"
printf      "############################\n$NORM"
