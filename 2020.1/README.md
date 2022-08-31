https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2020.1_0602_1208.tar.gz

# Vivado ML 2020.1 Docker image build

Before you build this Docker image, make sure you have downloaded the Xilinx Vivado ML installation file 
from [Vivado HLx 2020.1: All OS installer Single-File](https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2020.1_0602_1208.tar.gz). 
You will need an account in order to be able to download the installation file. 
The filename should be `Xilinx_Unified_2020.1_0602_1208.tar.gz` and should be 38.13 GB (make sure you have enough space in your drive).
Move the installer file to your desired directory, in my particular case, I moved the file from Downloads to my Home 
directory `mv ~/Downloads/Xilinx_Unified_2020.1_0602_1208.tar.gz ~/Xilinx_Unified_2020.1_0602_1208.tar.gz`

## Build the Docker image

This `Dockerfile` is exclusive to install Vivado ML and it is intended for a single use, after the installation, you can remove it to 
save space in your local drive.

```bash
cd 2020.1
VIVADO_ML_VERSION='2020.1'
docker buildx build --platform linux/amd64 -t vivado-${VIVADO_ML_VERSION}_installer . 
```

## Running the  Installer Docker Image

Once the built of `vivado-2020.1_installer` image is successfully completed, we have to identify the installation file and 
the installation source directory. The installation file is the tar.gz file downloaded from Xilnx official site, as mentioned 
above (the file `~/Xilinx_Unified_2020.1_0602_1208.tar.gz`, located in my home directory). For the installation source directory, 
you have to create one, in this example I created `Xilinx_source` in my home directory. When running the image, we have to 
mount two volumes,one for the installation file into '/opt/install_file/Xilinx_Unified_2020.1_0602_1208.tar.gz' and the source 
file directory to `/opt/source`.

For my example, the run command is as follows:
```bash
VIVADO_ML_VERSION='2020.1'
VIVADO_ML_INSTALLATION_FILE_NAME=Xilinx_Unified_2020.1_0602_1208.tar.gz
docker run --rm -it \
    -v ~/${VIVADO_ML_INSTALLATION_FILE_NAME}:/opt/install_file/${VIVADO_ML_INSTALLATION_FILE_NAME} \
    -v ~/Xilinx_source:/opt/source:rw \
    -v ~/Xilinx/${VIVADO_ML_VERSION}:/opt/Xilinx:rw \
    -e VIVADO_ML_VERSION="${VIVADO_ML_VERSION}" \
    -e VIVADO_ML_INSTALLATION_FILE="/opt/install_file/${VIVADO_ML_INSTALLATION_FILE_NAME}" \
    vivado-${VIVADO_ML_VERSION}_installer
```
The installation process takes a while. Once the installation is successfully finished, you are able to execute 
Vivado ML in a light weight Docker image, go to the [Build Docker Image Runner for Vivado ML](../README.md) 
section and follow the instructions.