# Vivado ML - Dockerized implementation for Mac and Ubuntu

This project is intended to create a dockerized installation for Vivado ML in a Mac or Ubuntu.
The current implementation is based from [https://github.com/phwl/docker-vivado/tree/master/2021.2](https://github.com/phwl/docker-vivado/tree/master/2021.2) 
and [https://github.com/aperloff/vivado-docker](https://github.com/aperloff/vivado-docker), but with some modifications to support 
the specific version covered here.

In order to be able to run Vivado ML, we should create an Installation image (choosing the desired available version)
and execute them to perform the installation. 

In a Second Step, we have to create a second Docker image to execute our installed Vivado ML version.

## Step 1 - Installing Vivado ML

If you already have the installation files in you computer (Ubuntu based installation), you can skipt this step and go directly to
the [Build Docker Image Runner for Vivado ML](#Run_Vivado_ML) section.

To install Vivao ML, we have the following versions available, pick one only one and follow the corresponding instructions.

- [Vivado ML 2021.2 ](2021.2/README.md)
- [Vivado ML 2020.1 ](2020.1/README.md)

To install Vivado, please follow the instruction [Install Vivado ML version 2021.2](2021.2/README.md) .

## Step 2 - Running Installed Vivado ML

For our Vivado ML installed version (chosen from Step 1) we need a Docker image to be able to run it. In this part we are going to
cover the image build process and the image execution. For the image execution we have some parameters to consider in order to have
a successfully run.

### 2.1 Build Vivado's Runner Docker Image

Based on the Vivado version you picked in the [Step 1](#Step_1_-_Installing_Vivado_ML)

In the terminal, move to the project directory, the one that have the `entrypoint.sh` in order to build the docker image
 with the `vivado-2021.2` tag:

```bash
docker buildx build --platform linux/amd64 -t vivado-2021.2 - <  DockerFile
```

At this point, you should have the installed files in `~/Xilinx`( directory used for our installation example above, 
locate the yours if you select a different one in the installation step) which we will used them to mount it as volume 
into `/opt/Xilinx` and be able to run the image for X11 or VNC options.

### 2.2 Run Docker Image  

#### Run using X11

We are assuming you are running this docker image under OSX and has XQuartz installed. We will need to make sure that XQuartz 
allows connections from network/remote clients. Open the menu at `XQuartz > Preferences...` and click on the `Security` tab. 
Make sure that the check box next to "Allow connections from network clients" is selected. You will need to restart XQuartz if 
this option wasn't enabled.

Add the local interface to the list of acceptable connections by doing `xhost + 127.0.0.1`. This needs to be done only when the 
xhost list is reset.

Now, you can run and open the remote program and start an x-window entering the following command:

```bash
docker run --rm -it \
    --net=host \
    -v ~/Xilinx:/opt/Xilinx:ro \
    -e DISPLAY=host.docker.internal:0 \
    vivado-2021.2
```


```bash
docker run --rm -it \
    --net=host \
    -v ~/Xilinx:/opt/Xilinx:ro \
    -v ~/Projects/MCD/hls-keras-example/my-hls-test:/home/vivado/work:rw \
    -e DISPLAY=host.docker.internal:0 \
    vivado-2021.2
```

```bash
docker run --rm -it \
    --net=host \
    -v ~/Xilinx:/opt/Xilinx:ro \
    -v ~/Projects/MCD/hls-keras-example/my-hls-test:/home/vivado/work:rw \
    -e DISPLAY=host.docker.internal:0 \
    vivado-2021.2
```

### Use the same IP Address

This is a less secure method of connecting the remote program to the X11 system on the host. This is because you are allowing the remote system to access the internet and then connect to your system's external IP address. While the xhost command does limit the connections to just that one address, this is still note the best practice and may get you booted off the network at final.

```bash
IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')  # use en1 for Wifi
xhost + $IP
docker run --rm -it \
    -e DISPLAY=$IP:0  \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/.Xauthority:/.Xauthority \
    -v ~/Xilinx:/opt/Xilinx:ro \
    vivado-2021.2
```

### Alternate Entrypoint

To override the entrypoint, you need to use the --entrypoint option. You may want to do this, for instance, if you want to open a bash terminal rather than Vivado directly.

```bash
IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')  # use en1 for Wifi
xhost + $IP
docker run --rm -it \
    -e DISPLAY=$IP:0 \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $PWD:/home/vivado/work \
    --entrypoint /bin/bash \
    vivado-2021.2 /opt/Xilinx/Vivado/2021.2/bin/vivado
```


### Connect enabling VNC

With VNC Server enabled, you will be asked for a password to set, you can set anyone. You can use the VNC Viewer 
to connect to localhost in the port 5900.

```bash
docker run --rm -it \
    -e START_VNC_SERVER=ON \
    -p 5900:5900 \
    -v ~/Xilinx:/opt/Xilinx:ro \
    vivado-2021.2
```
