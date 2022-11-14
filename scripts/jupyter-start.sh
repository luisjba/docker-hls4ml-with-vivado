#!/bin/bash
#
# This Script is tu run Jypyter Notebook
VIVADO_SHELL_SOURCE_FILE=${VIVADO_ML_HOME_DIR}/Vivado/${VIVADO_ML_VERSION}/settings64.sh
if [ ! -f ${HOME}/.bashrc ] || [ -z "$(grep $CONDA_ENV_NAME ${HOME}/.bashrc )" ]; then 
  source activate ${CONDA_ENV_NAME}
fi
[ -d ${HOME}/work ] || mkdir ${HOME}/work
jupyter notebook --notebook-dir=${HOME}/work --ip='*' --port=${PORT} --no-browser --allow-root