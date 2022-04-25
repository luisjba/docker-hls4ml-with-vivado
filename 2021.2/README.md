# Vivado ML Docker in Ubuntu

This Dockerfile is to create a Vivado ML 2021.2 installation under Ubuntu. This Dockerfile is based from [https://github.com/phwl/docker-vivado/tree/master/2021.2](https://github.com/phwl/docker-vivado/tree/master/2021.2) and [https://github.com/aperloff/vivado-docker](https://github.com/aperloff/vivado-docker), but with some modifications to support the latest version Vovao ML 2021.2_1021_0703.

Before you build this Docker image, make sure you have donwloaded the Xilinx Vivado ML installation file from [Xilinx Unified Installer 2021.2 SFD](https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2021.2_1021_0703.tar.gz) 
and move this installer file to this directory, in my particular case, I moved the file from the Donwloads directory to the project directory `mv ~/Downloads/Xilinx_Unified_2021.2_1021_0703.tar.gz ~/Projects/xilinx-vivado-docker/2021.2/Xilinx_Unified_2021.2_1021_0703.tar.gz`, you will need an account in
ordert to be able to donwload the installacion file. The filename should be `Xilinx_Unified_2021.2_1021_0703.tar.gz` and should be 71.9 GB (make shure you have enough space).

# Build Vivado Docker Image

Before build the image, make sure you have movet the installation file to the project directory `xilinx-vivado-docker/2021.2/Xilinx_Unified_2021.2_1021_0703.tar.gz`. This installation file must be in the same directory as the Dockerfile.

Move to the `2021.2` directory, set the imag tag name and build the image as follows:

```bash
cd 2021.2
docker image build -t vivado-2021.2 . 
```


## Run using X11

We are ssuming you are running this docker image under OSX and has XQuartz installed. We will need to make sure that XQuartz allows connections from network/remote clients. Open the menu at `XQuartz > Preferences...` and click on the `Security` tab. Make sure that the check box next to "Allow connections from network clients" is selected. You will need to restart XQuartz if this option wasn't already enabled.

Add the local interface to the list of acceptable connections by doing `xhost + 127.0.0.1`. This needs to be done only when the xhost list is reset.

Now, you can run and open the remote program and start an x-window, sue the command:

```bash
docker run --rm -it \
    --net=host \
    -e DISPLAY=host.docker.internal:0 \
    -v $PWD:/home/user/work \
    -w /home/user \
    vivado-2021.2 /opt/Xilinx/Vivado/2021.2/bin/vivado
```

### Use the same IP Address

This is a less secure method of connecting the remote program to the X11 system on the host. This is because you are allowing the remote system to access the internet and then connect to your system's external IP address. While the xhost command does limit the connections to just that one address, this is still note the best practice and may get you booted off the network at FNAL.

```bash
IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')  # use en1 for Wifi
xhost + $IP
docker run --rm -it \
    -e DISPLAY=$IP:0 \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $PWD:/home/user/work \
    -w /home/user \
    vivado-2021.2 /opt/Xilinx/Vivado/2021.2/bin/vivado

```

### Alternate Entrypoint

To override the entrypoint, you need to use the --entrypoint option. You may want to do this, for instance, if you want to open a bash terminal rather than Vivado directly.

```bash
docker run --rm -it \
    -e DISPLAY=$IP:0 \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $PWD:/home/user/work \
    -w /home/user \
    --entrypoint /bin/bash \
    vivado-2021.2 /opt/Xilinx/Vivado/2021.2/bin/vivado

```
