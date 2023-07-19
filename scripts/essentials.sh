#!/bin/bash

# Color for the script's messages.
CYAN='\033[1;36m'
NO_COLOR='\033[0m'

# Catch exit signal (CTRL + C), to terminate the whole script.
trap "exit" INT

# Update system.
echo -e "${CYAN}Updating system...${NO_COLOR}"
yes | sudo pacman -Syu

# Install essential packages, if they do not exist.
echo -e "${CYAN}Installing essential packages...${NO_COLOR}"
yes | sudo pacman -S --needed networkmanager base-devel git neovim \
    neofetch btop

# Install paru AUR helper.
echo -e "${CYAN}Installing paru AUR helper...${NO_COLOR}"
if command -v paru &>/dev/null; then
    echo -e "${CYAN}paru AUR helper, already exists in your system!${NO_COLOR}"
else

    # Delete old paru directory, if it exists.
    if [ -d "paru" ]; then
        echo -e "${CYAN}Deleting old paru directory...${NO_COLOR}"
        sudo rm -rf paru
    fi

    # Proceed with installation.
    git clone https://aur.archlinux.org/paru.git && cd paru &&
        yes | rustup default stable && yes | makepkg -si && cd .. &&
        sudo rm -rf paru
fi

# Configuring paru AUR helper.
echo -e "${CYAN}Configuring paru AUR helper...${NO_COLOR}"
echo -e "${CYAN}Enabling colors in terminal...${NO_COLOR}"
sed -i '/^#.*Color/s/^#//' /etc/pacman.conf
echo -e "${CYAN}Skipping review messages...${NO_COLOR}"
echo -e "SkipReview" >>/etc/paru.conf

# Installing the display manager.
echo -e "${CYAN}Installing display manager...${NO_COLOR}"
yes | paru -S --needed ly-git

# Configuring the display manager.
echo -e "${CYAN}Configuring display manager...${NO_COLOR}"
sudo systemctl enable ly
sed -i '/^#.*blank_password/s/^#//' /etc/ly/config.ini
