#!/bin/bash
# Provide the Vivado ML Installation file (.tar.gz) as the forst argument for 
# this installation script.
# We expect that the configuration file for Vivado ML is located in /opt/install_config.txt
# 
# MAINTAINER: Jose Luis Bracamonte Amavizca. <luisjba@gmail.com>
# Date Created: 2022-04-24
# Las Updated: 2022-04-25

VIVADO_ML_INSTALLATION_FILE=${1%/}
VIVADO_ML_CONFIG_FILE=/opt/install_config.txt
if [ -z $VIVADO_ML_INSTALLATION_FILE ]; then
  >&2 echo "The Installation File must be provided as the first argument."
  exit 1
fi
# Check that the installation file exists
if [ ! -f $VIVADO_ML_INSTALLATION_FILE ]; then
  >&2 echo "The instalation file $VIVADO_ML_INSTALLATION_DIR does not exists."
  exit 2
fi
# Check for valid file instalation file extension
if [ -z $(echo $VIVADO_ML_INSTALLATION_FILE | grep -E "\.tar.gz$") ]; then
  >&2 echo "Invalid instalation file $VIVADO_ML_INSTALLATION_DIR . The expected file must be a .tar.gz extension."
  exit 3
fi
# Check for configuration file
if [ ! -f $VIVADO_ML_CONFIG_FILE ]; then
  >&2 echo "$VIVADO_ML_CONFIG_FILE was not found, please provide the configuration file in the corresponding directory."
  exit 4
fi
# Retrive the Destination directory for Vivado ML
VIVADO_ML_DESTINATION=$(grep "^Destination=\(.\+\)" $VIVADO_ML_CONFIG_FILE | head -n 1 | cut -d"=" -f2)
if [ -z $VIVADO_ML_DESTINATION ]; then
  >&2 echo "The Destination configuration value is missing in $VIVADO_ML_CONFIG_FILE"
  exit 5
fi
# Get the base name from installation file an validate is valid
VIVADO_ML_INSTALLATION_BASENAME=$(basename $VIVADO_ML_INSTALLATION_FILE .tar.gz)
if [ -z $VIVADO_ML_INSTALLATION_BASENAME ]; then
  >&2 echo "Invalid base name for installation file $VIVADO_ML_INSTALLATION_FILE ."
  exit 6
fi
VIVADO_ML_INSTALLATION_SOURCE=/tmp/${VIVADO_ML_INSTALLATION_BASENAME}
# Check if tar file was already extracted
if [ ! -d ${VIVADO_ML_INSTALLATION_SOURCE} ]; then
  # Extract Tar files in a tmp folder
  echo "Extracting $VIVADO_ML_INSTALLATION_FILE into ${VIVADO_ML_INSTALLATION_SOURCE}"
  pv $VIVADO_ML_INSTALLATION_FILE | tar -xzf - --directory /tmp
fi
# check if xsetup exists
if [ ! -f ${VIVADO_ML_INSTALLATION_SOURCE}/xsetup ]; then
  >&2 echo "xsetup was not found in the installation directory: $VIVADO_ML_INSTALLATION_SOURCE"
  exit 7
fi
# Set the exucution permission to xsetup file
chmod +x ${VIVADO_ML_INSTALLATION_SOURCE}/xsetup
# Creating destination directory if not exists
if [ ! -d $VIVADO_ML_DESTINATION ]; then
  echo "Creating directory $VIVADO_ML_DESTINATION"
  mkdir -p $VIVADO_ML_DESTINATION
fi
vncserver :0
echo "Installing VIVADO ML from $VIVADO_ML_INSTALLATION_DIR"
${VIVADO_ML_INSTALLATION_SOURCE}/xsetup \
  --agree XilinxEULA,3rdPartyEULA,WebTalkTerms \
  --batch Install \
  --config ${VIVADO_ML_CONFIG_FILE}

# Removing installation files
echo "Successfuly installed Vivado Ml ${VIVADO_ML_INSTALLATION_BASENAME}"
echo "Deleting Instalation files from ${VIVADO_ML_INSTALLATION_SOURCE}"
rm -rf ${VIVADO_ML_INSTALLATION_SOURCE}
rm ${VIVADO_ML_INSTALLATION_FILE}
echo "Finished removed installation files"