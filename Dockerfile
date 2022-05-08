FROM ubuntu:18.04

LABEL mantainer="Jose Luis Bracamonte Amavizca <luisjba@gmail.com>"

# Install system libraries
RUN apt-get update \
    &&  apt-get -y upgrade \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      locales build-essential default-jre xorg libxrender-dev \
      libxtst-dev vnc4server twm pv vim sudo \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /tmp/
COPY vnc_xstartup /tmp/

# Vivado user setup, entrypoint and xtartup configuration
RUN mv /tmp/entrypoint.sh /usr/local/bin/xilinx_entrypoint \
  && chmod +x /usr/local/bin/xilinx_entrypoint \
  && mkdir -p /home/vivado/.vnc \
  && mv /tmp/vnc_xstartup /home/vivado/.vnc/xstartup \
  && useradd -ms /bin/bash vivado \
  && chown -R vivado /home/vivado

USER vivado
WORKDIR /home/vivado

ENV VIVADO_ML_HOME_DIR /opt/Xilinx
ENV VIVADO_ML_VERSION 2021.2
ENV GEOMETRY 1920x1200
ENV DISPLAY :0

ENTRYPOINT ["xilinx_entrypoint"]