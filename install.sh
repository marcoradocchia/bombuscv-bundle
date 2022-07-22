#!/bin/bash

# TODO: set capabilities for `datalogger`

# Colored output.
RED="\e[1;31m"
YELLOW="\e[1;33m"
GREEN="\e[1;32m"
CYAN="\e[1;36m"
NORM="\e[0m"

# Installation path.
BIN_DIR=$HOME/.local/bin

# Ask for reboot.
ask_reboot() 
{
  printf $GREEN"Please reboot your system before continung. Reboot now? [N/y]\n"
  printf $GREEN"==> "$NORM

  read selection # Read standard input.
  case $selection in
    Y|y)
      systemctl reboot
      ;;
    *)
      printf $YELLOW"==> Warning:$NORM changes will only be applied at next reboot\n"
      ;;
  esac
}

# Print error message and exit.
exit_msg() 
{
  printf $RED"==> Error:$NORM $1.\n"
  exit 1
}

# Check dependencies.
install_deps() 
{
  # Install raspi-config to enable I2C interface later.
  sudo apt-get install git raspi-config
  # If cargo isn't a command, install rustup.
  command -v cargo > /dev/null || {
    printf "$GREEN\n==> Installing rustup...$NORM\n"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  }
  # Can't install systemd if not already present: unrecoverable error.
  command -v systemctl > /dev/null || exit_msg "systemd required in order to use this software"
}

# Install `datalogger` + `bombuscv-display`
install_datalogger_display() 
{
  # Check if ~/.local/bin dir exists and it's in PATH.
  [ -d $BIN_DIR ] || mkdir -p $BIN_DIR
  echo $PATH | grep $HOME/.local/bin > /dev/null \
    || exit_msg "please add \$HOME/.local/bin to PATH"

  # Enable I2C interface with raspi-config in non-interactive mode.
  printf $GREEN"\n==> Enabling I2C interface...\n$NORM"
  sudo raspi-config nonint do_i2c 0

  printf $GREEN"\n==> Installing bombuscv-display...\n$NORM"
  # Clone `bombuscv-display` repository and compile with `release` flag.
  [ -d bombuscv-display ] || git clone https://github.com/marcoradocchia/bombuscv-display
  cd bombuscv-display
  cargo build --release
  # Install `bombuscv-display` to ~/.local/bin.
  install -Dm755 ./target/release/bombuscv-display -t $BIN_DIR
  cd ..
  rm -rf bombuscv-display

  printf $GREEN"\n==> Installing datalogger...\n$NORM"
  # Clone `datalogger` repository and compile with `release` flag.
  [ -d datalogger ] || git clone https://github.com/marcoradocchia/datalogger
  cd datalogger
  cargo build --release
  # Install `datalogger` to ~/.local/bin.
  install -Dm755 ./target/release/datalogger -t $BIN_DIR
  sudo setcap 'cap_sys_nice=eip' $BIN_DIR/datalogger
  cd ..
  rm -rf datalogger

  # TODO: make possible for the user to configure programs.
  # Customizing display-starter for the installing user.
  sed "s/<user>/$USER/" ./display-starter-template > display-starter
  # Install display-starter script (pipes datalogger output into bombuscv-display).
  install -Dm755 ./display-starter -t $BIN_DIR
  rm ./display-starter


  # Customizing bombuscv-display.service for the installing user.
  sed "s/<user>/$USER/" ./bombuscv-display-template.service > bombuscv-display.service
  # Install systemd service for datalogger and display.
  sudo install -Dm644 ./bombuscv-display.service -t /etc/systemd/system/
  rm ./bombuscv-display.service

  # Enable the service for boot startup.
  sudo systemctl enable bombuscv-display.service
}

# Install `bombuscv-rs`.
install_bombuscv() 
{
  printf $GREEN"\n==> Installing bombuscv-rs...\n$NORM"

  curl \
    --proto '=https' \
    --tlsv1.2 \
    -sSf https://raw.githubusercontent.com/marcoradocchia/bombuscv-rs/master/bombuscv-raspi.sh \
    | bash -s -- -m -u -r
}

# Print greeting message.
greet()
{
  printf "$CYAN\n############################\n"
  printf        "## Installation complete! ##\n"
  printf        "############################\n$NORM"
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

# Check if apt-get is a command on the system.
command -v apt-get > /dev/null || \
  exit_msg "please install RaspberryPi OS 64 bits and retry"

# Install updates & check dependencies.
printf "$GREEN==> Updating the system & installing dependencies...$NORM\n"
sudo apt-get update && sudo apt-get upgrade
install_deps

# User selection.
printf $GREEN"Please select desierd option:\n"$NORM
printf "  1) bombusv-rs\n"
printf "  2) datalogger + bombuscv-display\n"
printf "  3) complete bundle (bombusv-rs + datalogger + bombuscv-display)\n"
printf $GREEN"==> "$NORM

read selection # Read standard input.
case $selection in
  1) # Install `bombuscv-rs`.
    install_bombuscv
    ;;
  2) # Install `datalogger` + `bombuscv-display`.
    install_datalogger_display
    ;;
  3) # Install `bombuscv-rs` + `datalogger` + `bombuscv-display`.
    install_bombuscv
    install_datalogger_display
    ;;
  *) # Invalid option.
    printf $RED"invalid option:$NORM exiting...\n"
    exit 1
    ;;
esac && greet && ask_reboot
