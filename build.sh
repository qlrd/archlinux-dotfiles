#!/bin/bash

## These options are
## 'forked' from
## to https://github.com/raspiblitz/raspiblitz/blob/v1.9/build_sdcard.sh
## with some substitutions
me="${0##/*}"

nocolor="\033[0m"
red="\033[31m"

aur="paru"
defaultBranch="main"
defaultRepo="xrhstosmour/dotfiles"

## usage as a function to be called whenever there is a huge mistake on the options
usage(){
  printf %s"${me} [--option <argument>]

Options:
  -h, --help                               this help info
  -a, --aur [paru|yay]                     aur package manager
  -b, --branch                             branch to be built on (default: ${defaultBranch})
  -r, --repository                         repository to be checked from (default: ${defaultRepo})
Notes:
  all options, long and short accept --opt=value mode value
"
  exit 1
}

## default user message
error_msg(){ printf %s"${red}${me}: ${1}${nocolor}\n"; exit 1; }

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  usage
fi

# check if started with sudo
if [ "$EUID" -ne 0 ]; then 
  echo "error='run as root / may use sudo'"
  exit 1
fi

## assign_value variable_name "${opt}"
## it strips the dashes and assign the clean value to the variable
## assign_value status --on IS status=on
## variable_name is the name you want it to have
## $opt being options with single or double dashes that don't require arguments
assign_value(){
  case "${2}" in
    --*) value="${2#--}";;
    -*) value="${2#-}";;
    *) value="${2}"
  esac
  case "${value}" in
    0) value="false";;
    1) value="true";;
  esac
  ## Escaping quotes is needed because else if will fail if the argument is quoted
  # shellcheck disable=SC2140
  eval "${1}"="\"${value}\""
}

## get_arg variable_name "${opt}" "${arg}"
## get_arg service --service ssh
## variable_name is the name you want it to have
## $opt being options with single or double dashes
## $arg is requiring and argument, else it fails
## assign_value "${1}" "${3}" means it is assining the argument ($3) to the variable_name ($1)
get_arg(){
  case "${3}" in
    ""|-*) error_msg "Option '${2}' requires an argument.";;
  esac
  assign_value "${1}" "${3}"
}

## hacky getopts
## 1. if the option requires argument, and the option is preceeded by single or double dash and it
##    can be it can be specified with '-s=ssh' or '-s ssh' or '--service=ssh' or '--service ssh'
##    use: get_arg variable_name "${opt}" "${arg}"
## 2. if a bunch of options that does different things are to be assigned to the same variable
##    and the option is preceeded by single or double dash use: assign_value variable_name "${opt}"
##    as this option does not require argument, specifu $shift_n=1
## 3. if the option does not start with dash and does not require argument, assign to command manually.
while :; do
  case "${1}" in
    -*=*) opt="${1%=*}"; arg="${1#*=}"; shift_n=1;;
    -*) opt="${1}"; arg="${2}"; shift_n=2;;
    *) opt="${1}"; arg="${2}"; shift_n=1;;
  esac
  case "${opt}" in
    -a|-a=*|--aur|--aur=*) get_arg aur "${opt}" "${arg}";;
    -r|-r=*|--repository|--repository=*) get_arg repository "${opt}" "${arg}";;
    -b|-b=*|--branch|--branch=*) get_arg branch "${opt}" "${arg}";;
    "") break;;
    *) error_msg "Invalid option: ${opt}";;
  esac
  shift "${shift_n}"
done

## if there is a limited option, check if the value of variable is within this range
## $ range_argument variable_name possible_value_1 possible_value_2
range_argument(){
  name="${1}"
  eval var='$'"${1}"
  shift
  if [ -n "${var:-}" ]; then
    success=0
    for tests in "${@}"; do
      [ "${var}" = "${tests}" ] && success=1
    done
    [ ${success} -ne 1 ] && error_msg "Option '--${name}' cannot be '${var}'! It can only be: ${*}."
  fi
}

pacman_install(){
    pacman -S --needed ${@}
    if [ $? -eq 100 ]; then
        echo "FAIL! pacman failed to install needed packages!"
        echo ${@}
        exit 1
    fi
}

general_utils="base-devel git"

## loop all general_utils to see if program is installed (placed on PATH) and if not, add to the list of commands to be installed
for prog in ${general_utils}; do
  ! command -v ${prog} >/dev/null && general_utils_install="${general_utils_install} ${prog}"
done

## if any of the required programs are not installed, update and if successfull, install packages
if [ -n "${general_utils_install}" ]; then
  echo -e "\n*** SOFTWARE UPDATE ***"
  pacman -Syyuu || exit 1
  pacman_install ${general_utils_install}
fi

# AUR - PARU/YAY
# ---------------------------------------
if [ $aur = "paru" ] || [ $aur = "yay"]; then
  git clone https://aur.archlinux.org/${aur}.git /tmp/${aur}
  cd /tmp/${aur}
  makepkg -si
else
  echo "#error: ${aur} not supported" && exit 1
fi

## use default values for variables if empty

# GITHUB-USERNAME
# ---------------------------------------
# could be any valid github-user that has a fork of the raspiblitz repo - 'rootzoll' is default
# The 'raspiblitz' repo of this user is used to provisioning sd card with raspiblitz assets/scripts later on.
: "${repository:=$defaultRepo}"
curl --header "X-GitHub-Api-Version:2022-11-28" -s "https://api.github.com/repos/${repository}" | grep -q "\"message\": \"Not Found\"" && error_msg "Repository '${repository}' not found"

# GITHUB-BRANCH
# -------------------------------------
# could be any valid branch or tag of the given GITHUB-USERNAME forked raspiblitz repo
: "${branch:=$defaultBranch}"
curl --header "X-GitHub-Api-Version:2022-11-28" -s "https://api.github.com/repos/${repository}/branches/${branch}" | grep -q "\"message\": \"Branch not found\"" && error_msg "Repository '${repository}' does not contain branch '${branch}'"

echo "******************************************"
echo "*  Arch Linux configuration files setup  *"
echo "******************************************"
echo "For details on optional parameters - call with '--help' or check source code."

# output
for key in repository branch aur; do
  eval val='$'"${key}"
  [ -n "${val}" ] && printf '%s\n' "${key}=${val}"
done

git clone "https://github.com/${repository}.git"
cd $(echo "${repository}" | cut -d/ -f1)
git checkout $branch

chmod +x ./scripts/install.sh
./scripts/install.sh


