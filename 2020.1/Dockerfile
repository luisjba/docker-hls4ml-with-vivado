FROM ubuntu:18.04

LABEL mantainer="Jose Luis Bracamonte Amavizca <luisjba@gmail.com>"

# Install system libraries
RUN apt-get update \
    &&  apt-get -y upgrade \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      ca-certificates locales build-essential default-jre xorg libxrender-dev \
      libxtst-dev vnc4server twm pv vim sudo \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY install.sh /tmp/

# Vivado user configuration
RUN mv /tmp/install.sh /usr/local/bin/xilinx_install \
  && chmod +x /usr/local/bin/xilinx_install \
  && mkdir -p /home/vivado/.vnc \
  && useradd -ms /bin/bash vivado \
  && chown -R vivado /home/vivado

COPY install_config.txt /opt/install_config.txt

USER vivado
WORKDIR /home/vivado

ENV VIVADO_ML_VERSION 2020.1
ENV VIVADO_ML_INSTALLATION_FILE /opt/install_file/Xilinx_Unified_2020.1_0602_1208.tar.gz
ENV GEOMETRY 1920x1200
ENV DISPLAY :0
ENV START_VNC_SERVER OFF

CMD ["/bin/bash", "xilinx_install"]