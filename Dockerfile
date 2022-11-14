FROM ubuntu:18.04

LABEL mantainer="Jose Luis Bracamonte Amavizca <luisjba@gmail.com>"

# nstall system libraries
RUN apt-get update \
    &&  apt-get -y upgrade && \ 
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      bzip2 ca-certificates locales build-essential default-jre xorg libxrender-dev \
      libxtst-dev vnc4server twm pv vim sudo mercurial openssh-client subversion wget\
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxi6 \
    libxrender1 \
    libxrandr2 \
    libfreetype6 \
    libfontconfig \
    lsb-release \
    procps

  # Multilib support (workaround required by some configurations)
RUN apt-get update && apt-get install -y \
    gcc-multilib \
    g++-multilib && \
    ln -s /usr/lib/x86_64-linux-gnu /usr/lib64

# Clean
RUN apt-get clean && \
  apt-get autoremove && \
  rm -rf /var/lib/apt/lists/*

# Installation of miniconda -> https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/debian/Dockerfile

ENV PATH /opt/conda/bin:$PATH

# Leave these args here to better use the Docker build cache
ARG CONDA_VERSION=py39_4.12.0

RUN set -x && \
    UNAME_M="$(uname -m)" && \
    if [ "${UNAME_M}" = "x86_64" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh"; \
        SHA256SUM="78f39f9bae971ec1ae7969f0516017f2413f17796670f7040725dd83fcff5689"; \
    elif [ "${UNAME_M}" = "s390x" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-s390x.sh"; \
        SHA256SUM="ff6fdad3068ab5b15939c6f422ac329fa005d56ee0876c985e22e622d930e424"; \
    elif [ "${UNAME_M}" = "aarch64" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-aarch64.sh"; \
        SHA256SUM="5f4f865812101fdc747cea5b820806f678bb50fe0a61f19dc8aa369c52c4e513"; \
    elif [ "${UNAME_M}" = "ppc64le" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-ppc64le.sh"; \
        SHA256SUM="1fe3305d0ccc9e55b336b051ae12d82f33af408af4b560625674fa7ad915102b"; \
    fi && \
    wget "${MINICONDA_URL}" -O miniconda.sh -q && \
    echo "${SHA256SUM} miniconda.sh" > shasum && \
    if [ "${CONDA_VERSION}" != "latest" ]; then sha256sum --check --status shasum; fi && \
    mkdir -p /opt && \
    sh miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh shasum && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy



# Build arguments for Python version and conda env
ARG CONDA_ENV_NAME=hls4ml-py36
ARG CONDA_PYTHON_VERSION=3.6

# Install Python packages with conda into a new
# conda environment
RUN conda update conda
RUN conda create --copy --name ${CONDA_ENV_NAME} python=${CONDA_PYTHON_VERSION} && \
  conda install pytorch-cpu torchvision-cpu -c pytorch --name ${CONDA_ENV_NAME} -y && \
  conda install -c anaconda keras scikit-learn h5py pyyaml --name ${CONDA_ENV_NAME} -y

# Install jupyter notebbok
RUN conda install -c conda-forge jupyterlab --name ${CONDA_ENV_NAME} -y --quiet


COPY scripts/entrypoint.sh /tmp/
COPY scripts/vivado-start.sh /tmp/
COPY scripts/jupyter-start.sh /tmp/
COPY config/vnc_xstartup /tmp/

# Setup default user
ARG USER_ID=1000
ARG GROUP_ID=1000

# Vivado user setup, entrypoint and xtartup configuration
RUN mv /tmp/entrypoint.sh /usr/local/bin/xilinx_entrypoint && \
  chmod +x /usr/local/bin/xilinx_entrypoint && \
  mv /tmp/vivado-start.sh /usr/local/bin/vivado-start && \
  chmod +x /usr/local/bin/vivado-start && \
  mv /tmp/jupyter-start.sh /usr/local/bin/jupyter-start && \
  chmod +x /usr/local/bin/jupyter-start && \
  mkdir -p /home/vivado/.vnc && \
  mv /tmp/vnc_xstartup /home/vivado/.vnc/xstartup && \
  useradd -m -s /bin/bash -u ${USER_ID} -g ${GROUP_ID} vivado && \
  echo "vivado ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vivado && \
  chmod 0440 /etc/sudoers.d/vivado && \
  chown -R vivado:${GROUP_ID} /home/vivado

USER vivado
ENV HOME /home/vivado
WORKDIR /home/vivado

ENV CONDA_ENV_NAME=$CONDA_ENV_NAME
ENV PORT 8888
EXPOSE $PORT
ENV VIVADO_ML_HOME_DIR /opt/Xilinx
ENV VIVADO_ML_VERSION 2020.1
# The posible modes Vivado are gui|tcl|batch
ENV VIVADO_MODE gui
ENV GEOMETRY 1920x1200
ENV DISPLAY :0
ENV START_VNC_SERVER OFF

ENTRYPOINT ["xilinx_entrypoint"]
CMD ["jupyter-start"]