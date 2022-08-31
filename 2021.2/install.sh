#!/bin/bash
# Provide the Vivado ML Installation file (.tar.gz) as the forst argument for 
# this installation script.
# We expect that the configuration file for Vivado ML is located in /opt/install_config.txt
# 
# MAINTAINER: Jose Luis Bracamonte Amavizca. <luisjba@gmail.com>
# Date Created: 2022-04-24
# Las Updated: 2022-08-31

# VIVADO_ML_INSTALLATION_FILE=${1%/}
VIVADO_ML_CONFIG_FILE=/opt/install_config.txt
if [ -z $VIVADO_ML_INSTALLATION_FILE ]; then
  >&2 echo "The Installation File must be provided as the first argument."
  exit 1
fi
# Check that the installation file exists
if [ ! -f $VIVADO_ML_INSTALLATION_FILE ]; then
  >&2 echo "The instalation file $VIVADO_ML_INSTALLATION_FILE does not exists."
  exit 2
fi
# Check for valid file installation file extension
if [ -z $(echo $VIVADO_ML_INSTALLATION_FILE | grep -E "\.tar.gz$") ]; then
  >&2 echo "Invalid installation file $VIVADO_ML_INSTALLATION_FILE . The expected file must be a .tar.gz extension."
  exit 3
fi
# Get the base name from installation file an verify is a valid location
VIVADO_ML_INSTALLATION_BASENAME=$(basename $VIVADO_ML_INSTALLATION_FILE .tar.gz)
if [ -z $VIVADO_ML_INSTALLATION_BASENAME ]; then
  >&2 echo "Invalid base name for installation file $VIVADO_ML_INSTALLATION_FILE ."
  exit 4
fi
VIVADO_ML_INSTALLATION_SOURCE=/opt/source/${VIVADO_ML_INSTALLATION_BASENAME}
# Check if tar file was already extracted
if [ ! -d ${VIVADO_ML_INSTALLATION_SOURCE} ]; then
  # Extract Tar files in a tmp folder
  echo "Extracting $VIVADO_ML_INSTALLATION_FILE into ${VIVADO_ML_INSTALLATION_SOURCE}"
  pv ${VIVADO_ML_INSTALLATION_FILE} | tar -xzf - --directory /opt/source/
fi
# check if xsetup exists
if [ ! -f ${VIVADO_ML_INSTALLATION_SOURCE}/xsetup ]; then
  >&2 echo "xsetup was not found in the installation directory: $VIVADO_ML_INSTALLATION_SOURCE"
  exit 5
fi
# Set the exucution permission to xsetup file
chmod +x ${VIVADO_ML_INSTALLATION_SOURCE}/xsetup
echo "Installing VIVADO ML from $VIVADO_ML_INSTALLATION_SOURCE"
${VIVADO_ML_INSTALLATION_SOURCE}/xsetup \
  --agree XilinxEULA,3rdPartyEULA \
  --batch Install \
  --config ${VIVADO_ML_CONFIG_FILE}
if [ $? -gt 0 ]; then
  >&2 echo "Installation for Vivado ML failed: ${VIVADO_ML_INSTALLATION_SOURCE}/xsetup"
  exit 6
fi
echo "Successfuly installed Vivado Ml ${VIVADO_ML_INSTALLATION_BASENAME}"
true