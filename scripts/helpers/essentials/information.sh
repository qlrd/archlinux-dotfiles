#!/bin/bash

# Catch exit signal (CTRL + C), to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import functions and constant variables.
source "$SCRIPT_DIRECTORY/../functions.sh"
source "$SCRIPT_DIRECTORY/../../core/constants.sh"

# Constant variables for installing and configuring system information tool.
NEOFETCH_DIRECTORY="~/.config/neofetch"
NEOFETCH_CONFIGURATION="~/.config/neofetch/config.conf"
NEOFETCH_CONFIGURATION_TO_PASS="../configurations/information/neofetch.conf"

# Installing system information tool package.
install_packages "neofetch" "$AUR_PACKAGE_MANAGER" "Installing system information tool..."

# Configuring system information tool.
if [ ! -f "$NEOFETCH_CONFIGURATION" ] || ! diff "$NEOFETCH_CONFIGURATION_TO_PASS" "$NEOFETCH_CONFIGURATION" &>/dev/null; then
    echo -e "\n${BOLD_CYAN}Configuring system information tool...${NO_COLOR}"
    mkdir -p "$NEOFETCH_DIRECTORY" && cp -f "$NEOFETCH_CONFIGURATION_TO_PASS" "$NEOFETCH_CONFIGURATION"
fi
