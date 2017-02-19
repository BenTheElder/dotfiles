#!/bin/bash
#
# bootstrap dotfiles onto a machine

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#######################################
# Return if line is in file
# Globals:
#   LINE
#   FILE
# Arguments:
#   None
# Returns:
#   None
#######################################
line_present()
{
  grep -qsFx "${LINE}" ${FILE}
}

#######################################
# Sets up .bash_profile .bashrc to import common settings
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
bootstrap_bash()
{
  common_bash_inc="${DIR}/common.bash.inc"
  # canary line
  LINE="if [ -f ${common_bash_inc} ]; then"
  # files to check
  bash_files[0]=${HOME}"/.bash_profile"
  bash_files[1]=${HOME}"/.bashrc"
  # check all files and add the lines
  for bash_file in ${bash_files[@]}; do
    # ensure file exists
    if [[ ! -f ${bash_file} ]]; then
      touch ${bash_file}
    fi
    # ensure common 
    FILE=${bash_file}
    line_present
    if [[ "$?" -ne "0" ]]; then
      echo "Adding to: \`${FILE}\`."
      (
        set -x;
        echo "" >> ${FILE};
        echo "# source common settings from dotfiles" >> ${FILE};
        echo ${LINE} >> ${FILE};
        echo "  source ${common_bash_inc}" >> ${FILE};
        echo "fi" >> ${FILE};
        echo "" >> ${FILE};
      )
    fi
  done
  # source in current terminal
  source ${DIR}/common.bash.inc
}

#######################################
# Symlinks files in LINK_DIR to ~/
# Globals:
#   LINK_DIR
# Arguments:
#   None
# Returns:
#   None
#######################################
symlink_dir()
{
  if [ -d ${LINK_DIR} ]; then
    for link_file in $(find -L "${LINK_DIR}" -not -type d); do
      link_target="${HOME}"${link_file#$LINK_DIR}
      (
        set -x;
        ln -s ${link_file} ${link_target};
      )
    done
  fi
}

# entry point
main()
{
  echo "DIR := ${DIR}";
  echo "";
  read -p "Add \`common.bash.inc\`? (y/n): " -n 1 reply;
  echo "";
  if [[ ${reply} =~ ^[Y|y]$ ]]; then
    bootstrap_bash
  fi
  read -p "Symlink files in ./tilde to ~/ ? (y/n): " -n 1 reply;
  echo "";
  if [[ ${reply} =~ ^[Y|y]$ ]]; then
    LINK_DIR="${DIR}/tilde"
    symlink_dir
  fi
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "\nDetected macOS";
    read -p "Symlink files in ./tilde_macos to ~/ ? (y/n): " -n 1 reply;
    echo "";
    if [[ ${reply} =~ ^[Y|y]$ ]]; then
      LINK_DIR="${DIR}/tilde_macos"
      symlink_dir
    fi
  elif [[ "$OSTYPE"  == "linux-gnu" ]]; then
    echo "Detected Linux";
    read -p "Symlink files in ./tilde_linux to ~/ ? (y/n): " -n 1 reply;
    echo "";
    if [[ ${reply} =~ ^[Y|y]$ ]]; then
      LINK_DIR="${DIR}/tilde_linux"
      symlink_dir
    fi
  fi
}

main "$@"
