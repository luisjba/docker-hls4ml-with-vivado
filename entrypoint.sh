#!/bin/bash
#
# VIVADO_ML_VERSION => Env variable with the target Vivao ML Version

VIVADO_ML_CONFIG_FILE=/opt/install_config.txt
# Check for configuration file
if [ ! -f $VIVADO_ML_CONFIG_FILE ]; then
  >&2 echo "$VIVADO_ML_CONFIG_FILE was not found, please provide the configuration file in the correponding directory."
  exit 1
fi
# Retrive the Destination directory for Vivado ML
VIVADO_ML_DESTINATION=$(grep "^Destination=\(.\+\)" $VIVADO_ML_CONFIG_FILE | head -n 1 | cut -d"=" -f2)
if [ -z $VIVADO_ML_DESTINATION ]; then
  >&2 echo "The Destination configuration value is missing in $VIVADO_ML_CONFIG_FILE"
  exit 2
fi
VIVADO_EXEC=${VIVADO_ML_DESTINATION}/Vivado/${VIVADO_ML_VERSION}/bin/vivado
# Verify Vivao ML installation is present
if [ ! -f ${VIVADO_EXEC} ]; then
  >&2 echo "Vivia ML instalation not found in  $VIVADO_EXEC"
  exit 3
fi
# check if settings are present in .bashhr
if [ ! -f /home/vivado/.bashrc ]; then 
  echo "source ${VIVADO_ML_DESTINATION}/Vivado/${VIVADO_ML_VERSION}/settings64.sh" >> /home/vivado/.bashrc
fi 

vncserver -geometry ${GEOMETRY} :0
${VIVADO_EXEC}