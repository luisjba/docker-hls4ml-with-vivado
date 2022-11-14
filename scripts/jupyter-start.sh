#!/bin/bash
#
# This Script is tu run Jypyter Notebook
echo "Activating conda environment: ${CONDA_ENV_NAME}"
source activate ${CONDA_ENV_NAME}
[ -d ${HOME}/work ] || mkdir ${HOME}/work
echo "Execution Jypyter from: `which jupyter`"
jupyter notebook \
  --notebook-dir=${HOME}/work --ip='*' \
  --port=${PORT} --no-browser --allow-root