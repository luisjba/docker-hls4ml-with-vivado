#!/bin/bash
#
# This Script is tu run Vivado ML with the different modes gui|tcl|batch
# script_file required only for batch mode
script_file=$1
vivado_executor=${VIVADO_ML_HOME_DIR}/Vivado/${VIVADO_ML_VERSION}/bin/vivado
if [ "$VIVADO_MODE" = "batch" ]; then
  # check the script file 
  if [ -z $script_file ]; then 
    >&2 echo "For batch mode, the script file must be specified as parameter"
    exit 1
  fi
  if [ ! -f ${script_file} ]; then
    >&2 echo "Script file not found in ${script_file}"
    exit 2
  fi
  echo "Starting Vivado in batch mode. Tcl script: ${script_file}"
  ${vivado_executor} -mode batch -source ${script_file}
else
  echo "Launching Vivado"
  echo "Mode: ${VIVADO_MODE}"
  echo "X11: DISPLAY=${DISPLAY}"
  if [ "$VIVADO_MODE" = "tcl" ]; then
    echo "Note: use 'start_gui' and 'stop_gui' Tcl commands to open and close the Vivado IDE from the Tcl shell"
  fi
  ${vivado_executor} -mode ${VIVADO_MODE}
fi