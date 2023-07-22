#!/bin/bash

# Color for the script's messages.
CYAN='\033[1;36m'
NO_COLOR='\033[0m'

# Catch exit signal (CTRL + C), to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Installing development tools.
echo -e "\n${CYAN}Installing development tools...${NO_COLOR}"
paru -S --noconfirm --needed vscodium-bin remmina-git gitkraken obsidian \
    postman-bin etcher-bin docker docker-compose

# Configuring development tools.
echo -e "Configuring development tools..."
sudo systemctl enable docker && sudo systemctl start docker

# Installing programming languages.
echo -e "\n${CYAN}Installing programming languages...${NO_COLOR}"

# Installing Python.
echo -e "\n${CYAN}Installing Python...${NO_COLOR}"
paru -S --noconfirm --needed python python-pip python-poetry python-poetry-plugin-up

# Configuring Python.
echo -e "\n${CYAN}Configuring Python...${NO_COLOR}"

# Configuring Poetry.
echo -e "\n${CYAN}Configuring Poetry...${NO_COLOR}"
poetry config virtualenvs.in-project true
