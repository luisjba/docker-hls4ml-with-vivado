# Docker Image for Vivado ML Installation under Ubuntu

Before you build this Docker image, make sure you have downloaded the Xilinx Vivado ML installation file 
from [Xilinx Unified Installer 2021.2 SFD](https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2021.2_1021_0703.tar.gz) 
and move this installer file to your desired directory, in my particular case, I moved the file from Downloads to my Home 
directory `mv ~/Downloads/Xilinx_Unified_2021.2_1021_0703.tar.gz ~/2021.2/Xilinx_Unified_2021.2_1021_0703.tar.gz`, you will 
need an account in order to be able to download the installation file. The filename should be `Xilinx_Unified_2021.2_1021_0703.tar.gz`
and should be 71.9 GB (make sure you have enough space in your drive).

## Build and 

This `Dockerfile` is exclusive to install Vivado ML and you will use them only once. After installing, you can remove it to 
save space in your local drive.

```bash
cd 2021.2
docker buildx build --platform linux/amd64 -t vivado-2021.2_installer . 
```

## Running the  Installer Docker Image

Once the built of `vivado-2021.2_installer` image was completed successfully, we have to identify the installation file and 
the installation source directory. The installation file is the tar.gz file downloaded from Xilnx official site, as mentioned 
above (the file `~/Xilinx_Unified_2021.2_1021_0703.tar.gz`, located in my home directory). For the installation source directory, 
you have to create one, in this example I created `Xilinx_source` in my home directory. When running the image, we have to 
mount two volumes,one for the installation file into '/opt/install_file/Xilinx_Unified_2021.2_1021_0703.tar.gz' and the source 
file directory to `/opt/source`.

For my example, the run command is as follows:
```bash
docker run --rm -it \
    -v ~/Xilinx_Unified_2021.2_1021_0703.tar.gz:/opt/install_file/Xilinx_Unified_2021.2_1021_0703.tar.gz \
    -v ~/Xilinx_source:/opt/source:rw \
    -v ~/Xilinx:/opt/Xilinx:rw \
    vivado-2021.2_installer
```
The installation process take a while. Once the installation finished successfully, you are ready to execute 
Vivado ML in a light weight Docker image, go to the [Build Docker Image Runner for Vivado ML](../../README.md) 
section and follow the instructions.