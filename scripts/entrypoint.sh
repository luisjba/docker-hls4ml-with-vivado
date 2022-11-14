#!/bin/bash
# MAINTAINER: Jose Luis Bracamonte Aamavizca <luisjba@gmail.com>
# Date Created: 2022-08-08
# Las Updated: 2022-11-10
cat >${HOME}/motd <<EOL
v 1.0
 _          _       _      _  _
| |_  _ _  | | _ _ <_> ___<_>| |_  ___
| . \| | | | || | || |<_-<| || . \<_> |
|___/\_  | |_| ___||_|/__/| ||___/<___|
     <___|               <__|
This docker Instance have installed hls4ml with Vivado ML.
It upports execution of Vivado ML GUI and connect via X11 or VNC. 
By default executes a Jupyter notebbokrunning on port ${PORT} 
with ${HOME}/work as notebook directory (recomended to mount your
local diredtory on it via volumne with docker).
Python version : `python --version | head -n 1 | awk '{print $2}'`
Conda Environment: ${CONDA_ENV_NAME}
MAINTAINER: Jose Luis Bracamonte Amavizca. <luisjba@gmail.com>
-------------------------------------------------------------------------
EOL
cat ${HOME}/motd
rm ${HOME}/motd

# Verify Vivao ML installation is present
VIVADO_EXEC=${VIVADO_ML_HOME_DIR}/Vivado/${VIVADO_ML_VERSION}/bin/vivado
if [ ! -f ${VIVADO_EXEC} ]; then
  >&2 echo "Vivado ML instalation not found in $VIVADO_EXEC"
  exit 1
fi
if [ "$START_VNC_SERVER" = "ON" ]; then
  vncserver -geometry ${GEOMETRY} ${DISPLAY}
fi
$(eval "echo $@")