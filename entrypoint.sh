#!/bin/bash
#
# VIVADO_ML_HOME_DIR => Env varibale fo Vivamo Ml installation directory.
# VIVADO_ML_VERSION => Env variable with the target Vivao ML Version.

VIVADO_EXEC=${VIVADO_ML_HOME_DIR}/Vivado/${VIVADO_ML_VERSION}/bin/vivado
# Verify Vivao ML installation is present
if [ ! -f ${VIVADO_EXEC} ]; then
  >&2 echo "Vivia ML instalation not found in $VIVADO_EXEC"
  exit 1
fi
# check if settings are present in .bashhr
if [ ! -f /home/vivado/.bashrc ]; then 
  echo "source ${VIVADO_ML_HOME_DIR}/Vivado/${VIVADO_ML_VERSION}/settings64.sh" >> /home/vivado/.bashrc
fi 

vncserver -geometry ${GEOMETRY} ${DISPLAY}
${VIVADO_EXEC}