FROM osrf/ros:melodic-desktop-full
ARG DEBIAN_FRONTEND=noninteractive
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list

### nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub

RUN apt-get update \
  && apt-get install -y lsb-release gnupg

### install ros 
# RUN sh -c '. /etc/lsb-release && echo "deb http://mirrors.tuna.tsinghua.edu.cn/ros/ubuntu/ `lsb_release -cs` main" > /etc/apt/sources.list.d/ros-latest.list'
# RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# RUN apt-get update \
#  && apt-get install -y ros-melodic-desktop-full \
#  && apt-get install -y vim inputils-ping openssh-server \
#  && echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc \
#  && apt-get -y update --fix-missing \
#  && apt-get clean \
#  && rm -rf /var/lib/apt/lists/*


### install basic tools
USER root
RUN apt-get update && \
    apt-get install -y sudo && \
    apt-get install -y wget git && \
    apt-get install -y vim && \
    apt-get install -y htop tmux && \
    apt-get install -y zip unzip && \
    apt-get install -y libjpeg-dev libtiff5-dev


RUN adduser --disabled-password --gecos '' nx
RUN adduser nx sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers


### user
USER nx
WORKDIR /home/nx
CMD /bin/bash

### bashrc
RUN echo "" >> ~/bashrc.sh
RUN echo "source ~/bashrc.sh" >> ~/.bashrc

### tmux config
RUN echo "set -g prefix C-x" >> ~/.tmux.conf
RUN echo "unbind C-b" >> ~/.tmux.conf
RUN echo "bind C-x send-prefix" >> ~/.tmux.conf

SHELL ["/bin/bash", "-c"]

RUN mkdir opt && cd opt && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.8.3-Linux-x86_64.sh && \
    # chmod +x Miniconda3-py37_4.8.3-Linux-x86_64.sh && \
    sh Miniconda3-py37_4.8.3-Linux-x86_64.sh -b && \
    ~/miniconda3/bin/conda init && \
    source ~/.bashrc 

ENV PATH=~/miniconda3/bin:$PATH

SHELL ["/bin/bash", "--login", "-c"]

RUN pip install numpy==1.20.2                       && \
    pip install scipy==1.6.1                        && \
    pip install matplotlib==3.3.4                   && \
    pip install seaborn==0.11.1                     && \
    pip install gym==0.18.0                         && \
    pip install pygame==1.9.6                       && \
    pip install networkx==2.5                       && \
    pip install PyYAML==5.4.1                       && \
    pip install python-intervals==1.10.0.post1      && \
    pip install opencv-python==4.3.0.36             && \
    pip install open3d==0.8.0.0                     && \
    pip install tensorboardX==2.1                   && \
    pip install tensorboard==2.4.1                  && \
    pip install psutil==5.8.0                       && \
    pip install pynvml==8.0.4                       && \
    pip install Shapely==1.7.1                      && \
    pip install termcolor==1.1.0                    && \
    pip install memory-profiler==0.60.0

### torch
RUN cd ~/opt && \
    wget https://download.pytorch.org/whl/cu111/torch-1.9.1%2Bcu111-cp37-cp37m-linux_x86_64.whl && \
    wget https://download.pytorch.org/whl/cu111/torchvision-0.10.1%2Bcu111-cp37-cp37m-linux_x86_64.whl && \
    pip install torch-1.9.1+cu111-cp37-cp37m-linux_x86_64.whl && \
    pip install torchvision-0.10.1+cu111-cp37-cp37m-linux_x86_64.whl
