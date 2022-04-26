FROM ubuntu:18.04

LABEL mantainer="Jose Luis Bracamonte Amavizca <luisjba@gmail.com>"

# Install system libraries
RUN apt-get update \
    &&  apt-get -y upgrade \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      build-essential default-jre xorg libxrender-dev libxtst-dev vnc4server twm pv vim sudo \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Set the target Vivado ML Version
ENV VIVADO_ML_VERSION 2021.2
## Set the installation file. This file must be donwloaded form the official site 
## https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2021.2_1021_0703.tar.gz and 

## you will need an account iin ordert to be able to download the installation file.
ARG INSTALL_FILE="Xilinx_Unified_2021.2_1021_0703.tar.gz"
## Copy files used to configure and install Vivado ML
COPY install_config.txt /opt/install_config.txt
COPY install.sh /opt/install.sh
COPY ${INSTALL_FILE} /opt/${INSTALL_FILE}

# Vivado ML Installation
RUN chmod +x /opt/install.sh && /opt/install.sh /opt/${INSTALL_FILE} && rm -rf /tmp/.X*

# Vivado user configuration
RUN mkdir -p /home/vivado/.vnc \
  && useradd -ms /bin/bash vivado \
  && chown -R vivado /home/vivado \
  && echo "source /opt/Xilinx/Vivado/${VIVADO_ML_VERSION}/settings64.sh" >> /home/vivado/.bashrc

COPY xstartup /home/vivado/.vnc/xstartup
COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

USER vivado
WORKDIR /home/vivado

ENV DISPLAY :0
ENV GEOMETRY 1920x1200

ENTRYPOINT ["/opt/entrypoint.sh"]