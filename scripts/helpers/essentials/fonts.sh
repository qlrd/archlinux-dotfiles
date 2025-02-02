#!/bin/bash

# Catch exit signal (CTRL + C), to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
FONTS_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import functions.
source "$FONTS_SCRIPT_DIRECTORY/../functions/packages.sh"

# ? Importing constants.sh is not needed, because it is already sourced in the logs script.
# ? Importing logs.sh is not needed, because it is already sourced in the other function scripts.

# Constant variable for the fonts to install.
FONTS="ttf-firacode-nerd"

# Check if at least one font is not installed.
are_font_packages_installed=$(are_packages_installed "$FONTS" "$AUR_PACKAGE_MANAGER")
if [ "$are_font_packages_installed" = "false" ]; then
    log_info "Installing fonts..."

    # Install fonts.
    install_packages "$FONTS" "$AUR_PACKAGE_MANAGER"
fi
