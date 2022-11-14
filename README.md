# Python hls4ml with Vivado ML and jupyter - Dockerized implementation for Mac and Ubuntu

# Table of contents
1. [Introduction](#introduction)
2. [Downloading project](#introduction)
3. [Installing Vivado ML](#installing-vivado-ml)
4. [Build Docker image for hs4ml with Vivado](#build-docker-image-for-hs4ml-with-vivado)
5. [Run Docker image hls4ml with Vivado](#run-docker-image-hls4ml-with-vivado)
    - [Run Vivado GUI using X11](#run-vivado-gui-using-x11)
        - [Run with localhost ip](#run-with-localhost-ip)
        - [Run using same ip address (the en0 Mac wifi interface)](#run-using-same-ip-address-the-en0-mac-wifi-interface)
    - [Run Vivado GUI and connect via VNC](#run-vivado-gui-and-connect-via-vnc)
6. [Run Jupyter Notebook](#run-jupyter-notebook)
7. [Alternate Entrypoint](#alternate-entrypoint)

## Introduction

This project is intended to create a dockerize installation for Vivado ML in a Mac or Ubuntu with the library HLS4ML.
The current implementation is based from 
[https://github.com/phwl/docker-vivado/tree/master/2021.2](https://github.com/phwl/docker-vivado/tree/master/2021.2) 
and [https://github.com/aperloff/vivado-docker](https://github.com/aperloff/vivado-docker), but with some modifications to support 
the specific version covered here.

In order to be able to run Vivado ML, we should create an Installation image (choosing the desired available version)
and execute them to perform the installation saved in our local computer (mounting a volume). 

In a Second Step, we have to create a second Docker image to execute our installed Vivado ML version mounting the
volume containing the installation of Vivado ML.


## Downloading project

In order to follow the next steps, you have to download this repository in your local computer, I usually have a `Projects` folder 
in which a place all projects repositories (fell free to use the one you desire) and for propose of thi documentations I am
going to refer to this directory as part of the location of the downloaded repository.

Download the repo.
```bash
# Move to the project directory
cd ~/Projects

# Clone the repo
git clone https://github.com/luisjba/docker-hls4ml-with-vivado.git

# Enter into the downloaded repository folder
cd docker-hls4ml-with-vivado
```

Now, you can go to the next steps to install Vivado or build the runner image if you already have Vivado installed.

## Installing Vivado ML

If you already have the installation files in you computer (Ubuntu based installation), you can skip this step and go directly to
the [Build Docker image for hs4ml with Vivado](#build-docker-image-for-hs4ml-with-vivado) section.

To install Vivao ML, we have the following versions available, pick one only one and follow the corresponding instructions.

- [Vivado ML 2020.1 ](2020.1/README.md) (we recommend to use this version, will be used in this implementation)
- [Vivado ML 2021.2 ](2021.2/README.md)


To install Vivado, please follow the instruction [Install Vivado ML version 2020.1](2020.1/README.md).

## Build Docker image for hs4ml with Vivado

Open your terminal and move to the project directory, the one that have the folders `config` and `scripts`.
Run the build command with the parameters and selected version for Vivado.

```bash
VIVADO_ML_VERSION='2020.1'
docker buildx build --platform linux/amd64 \
    --network=host \
    --build-arg USER_ID=`id -u` \
    --build-arg GROUP_ID=`id -g` \
    -t hls4ml-with-vivado-${VIVADO_ML_VERSION} .
```

## Run Docker image hls4ml with Vivado

Based on the Vivado version you picked in above section [Installing Vivado ML](#installing-vivado-ml), 
you have to locate the installation directory in your
computer, in this implementation we have used the directory `~/Xilinx` and we are going to mount it as volume when executing the
generated image in the section [Build Docker image for hs4ml with Vivado](#build-docker-image-for-hs4ml-with-vivado) to be able to run the image with X11 or VNC.

### Run Vivado GUI using X11

We are assuming you are running this docker image under OSX and has XQuartz installed. We have to make sure XQuartz 
allows connections from network/remote clients. To configure it, open XQuartz and go to `XQuartz > Preferences...` 
then click on the `Security` tab. 
Make sure the check box "Allow connections from network clients" is selected. You will need to restart XQuartz if 
this option wasn't enabled.

To add ip addresses to to the list of acceptable connection whe should execute `xhost + 127.0.0.1` for localhost and
`xhost + $(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')` for same ip address of the wifi interface (in a mac).

#### Run with localhost ip

After running the `vivado-start` command at the end of all docker parameters, the GUI of Vivado program will be open automatically. 
Note we have to add localhost address with `xhost + 127.0.0.1`, map `.x11-unix` and Vivado ML installation folder 
`~/Xilinx/${VIVADO_ML_VERSION}` as volumes into to container.

---
**NOTE** 

Do not forget to add the network option as host as part of the docker run parameters `--net=host `.
---

```bash
xhost + 127.0.0.1
VIVADO_ML_VERSION='2020.1'
docker run --rm -it \
    --name hls4ml-with-vivado-gui \
    --net=host \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/Xilinx/${VIVADO_ML_VERSION}:/opt/Xilinx:ro \
    -e DISPLAY=host.docker.internal:0 \
    hls4ml-with-vivado-${VIVADO_ML_VERSION} vivado-start
```

There is the `VIVADO_MODE` environment variable that we can use to change the supported execution modes:
- **gui:** This is the default value, it opens the Vivado IDE GUI.
- **tcl:** Open the Tcl Shell. You can start the GUI with `start_gui` tlc command or stop it
with `stop_gui` command.
- **batch:** This mode receives a script file to execute and after executing the toll exits.

Running with tlc mode:

```bash
xhost + 127.0.0.1
VIVADO_ML_VERSION='2020.1'
docker run --rm -it \
    --name hls4ml-with-vivado-gui \
    --net=host \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/Xilinx/${VIVADO_ML_VERSION}:/opt/Xilinx:ro \
    -e DISPLAY=host.docker.internal:0 \
    -e VIVADO_MODE=tcl \
    hls4ml-with-vivado-${VIVADO_ML_VERSION} vivado-start
```

Running with batch mode: for this mod, a tcl script is required and have to be passed as argument after `vivado-start` command.

```bash
xhost + 127.0.0.1
VIVADO_ML_VERSION='2020.1'
docker run --rm -it \
    --name hls4ml-with-vivado-gui \
    --net=host \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/Xilinx/${VIVADO_ML_VERSION}:/opt/Xilinx:ro \
    -e DISPLAY=host.docker.internal:0 \
    -e VIVADO_MODE=batch \
    hls4ml-with-vivado-${VIVADO_ML_VERSION} vivado-start my_script.tcl
```

#### Run using same ip address (the en0 Mac wifi interface)

This is a less secure method of connecting the remote program to the X11 system on the host. This is because you are allowing the remote system to access the internet and then connect to your system's external IP address. While the `xhost` command does limit the connections to just that one address, this is still note the best practice and may get you booted off the network at final.

To capture the IP for the interface and store into the `IP` variable we can use the `ifconfig en0` to lookup 
for the interface information and add extra commands (`grep` and `awk`) to get the ip value. In the first
line of the command we are assigning the IP address value into the `IP` variable with the command
`IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')` and use the value to add the IP to the list
with `xhost + $IP` command. And we have to change the `DISPLAY` env value adding the IP address with the
values `DISPLAY=$IP:0` .

---
**NOTE** 

Do not forget to add the network option as host as part of the docker run parameters `--net=host `.
---

The complete commands are the following.

```bash
IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
xhost + $IP
VIVADO_ML_VERSION='2020.1'
docker run --rm -it \
    --name hls4ml-with-vivado-gui \
    --net=host \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/Xilinx/${VIVADO_ML_VERSION}:/opt/Xilinx:ro \
    -e DISPLAY=$IP:0 \
    hls4ml-with-vivado-${VIVADO_ML_VERSION} vivado-start
```

### Run Vivado GUI and connect via VNC

With VNC Server enabled, you will be asked for a password to set, you can set anyone. You can use the VNC Viewer 
or any other VNC client you have to connect to localhost in the port 5900.

```bash
VIVADO_ML_VERSION='2020.1'
docker run --rm -it \
    --name hls4ml-with-vivado-gui-vnc \
    -e START_VNC_SERVER=ON \
    -p 5900:5900 \
    -v ~/Xilinx/${VIVADO_ML_VERSION}:/opt/Xilinx:ro \
    hls4ml-with-vivado-${VIVADO_ML_VERSION} vivado-start
```


## Run Jupyter Notebook

For jupyter notebook, the server by default starts in the port 8888, but can be configured by `PORT` environment variable.
---
**NOTE:** we are mapping our host port to 8080. Jupyter is accessible 
from http://127.0.0.1:8080/?token=<token>
---

```bash
VIVADO_ML_VERSION='2020.1'
docker run --rm -it \
    --name hls4ml-with-vivado-jnb \
    --net=host \
    -p 8080:8888 \
    -v ~/Xilinx/${VIVADO_ML_VERSION}:/opt/Xilinx:ro \
    hls4ml-with-vivado-${VIVADO_ML_VERSION} jupyter-start
```

The notebook dir in the container is `/home/vivado/work`, if you want to connect you local files
in the notebook map ip with a volume. For demo propose I have in my local computer the notebook dir 
in `~/Projects/MCD/hls-keras-example`, use yours when running it.

```bash
VIVADO_ML_VERSION='2020.1'
docker run --rm -it \
    --name hls4ml-with-vivado-jnb \
    -p 8080:8888 \
    -v ~/Xilinx/${VIVADO_ML_VERSION}:/opt/Xilinx:ro \
    -v ~/Projects/MCD/hls-keras-example:/home/vivado/work:rw \
    hls4ml-with-vivado-${VIVADO_ML_VERSION} jupyter-start
```

## Alternate Entrypoint

To override the entrypoint, you need to use the --entrypoint option. You may want to do this, for instance, if you want to open a bash terminal rather than Vivado directly.

```bash
xhost + 127.0.0.1
VIVADO_ML_VERSION='2020.1'
docker run --rm -it \
    --name hls4ml-with-vivado-gui \
    --net=host \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/Xilinx/${VIVADO_ML_VERSION}:/opt/Xilinx:ro \
    -e DISPLAY=host.docker.internal:0 \
    -v $PWD:/home/vivado/work \
    --entrypoint /bin/bash \
    hls4ml-with-vivado-${VIVADO_ML_VERSION} /opt/Xilinx/Vivado/${VIVADO_ML_VERSION}/bin/vivado
```