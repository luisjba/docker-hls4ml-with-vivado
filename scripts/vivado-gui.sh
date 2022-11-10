#!/bin/bash
#
# This Script is tu run Vivado ML GUI
VIVADO_SHELL_SOURCE_FILE=${VIVADO_ML_HOME_DIR}/Vivado/${VIVADO_ML_VERSION}/settings64.sh
if [ ! -f ${HOME}/.bashrc ] || [ -z "$(grep $VIVADO_SHELL_SOURCE_FILE ${HOME}/.bashrc )" ]; then 
  source ${VIVADO_SHELL_SOURCE_FILE}
fi
echo "Starting Vivado ML GUI - X11 DISPLAY:$DISPLAY"
${VIVADO_ML_HOME_DIR}/Vivado/${VIVADO_ML_VERSION}/bin/vivado