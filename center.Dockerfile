FROM nvidia/cuda:11.1.1-cudnn8-runtime-ubuntu18.04

# 设置环境变量
ENV DEBIAN_FRONTEND noninteractive
ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics,compat32,utility,display

# 用root用户安装依赖
USER root 

# 更换阿里云源，在国内可以加快速度
RUN sed -i "s/security.ubuntu.com/mirrors.aliyun.com/" /etc/apt/sources.list && \
    sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/" /etc/apt/sources.list && \
    sed -i "s/security-cdn.ubuntu.com/mirrors.aliyun.com/" /etc/apt/sources.list
RUN apt-get clean

# cuda GPG key
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub

# 安装ros-melodic-desktop-full
RUN apt-get update && apt-get install -y lsb-release gnupg

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN apt-get update \
 && apt-get install -y ros-melodic-desktop-full \
 && apt-get install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential \
 && echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc \
 && apt-get -y update --fix-missing \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# 更新源，安装相应工具
RUN apt-get update && apt-get install -y \
    build-essential \
    openssh-server \
    net-tools \
    cmake \
    vim \
    git \
    wget \
    curl \
    zip \
    unzip \
    htop \
    dbus \
    tmux 

# 创建nx用户
RUN adduser --disabled-password --gecos '' nx && \
    adduser nx sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# 为nx用户安装依赖
USER nx
WORKDIR /home/nx
CMD /bin/bash

# bashrc
RUN echo "" >> ~/bashrc.sh
RUN echo "source ~/bashrc.sh" >> ~/.bashrc

# tmux config
RUN echo "set -g prefix C-x" >> ~/.tmux.conf && \
    echo "unbind C-b" >> ~/.tmux.conf && \
    echo "bind C-x send-prefix" >> ~/.tmux.conf && \
    echo "set -g mouse on" >> ~/.tmux.conf

SHELL ["/bin/bash", "-c"]

# 安装miniconda
RUN mkdir opt && cd opt && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.8.3-Linux-x86_64.sh && \
    # chmod +x Miniconda3-py37_4.8.3-Linux-x86_64.sh && \
    sh Miniconda3-py37_4.8.3-Linux-x86_64.sh -b && \
    ~/miniconda3/bin/conda init && \
    source ~/.bashrc 

ENV PATH=~/miniconda3/bin:$PATH

SHELL ["/bin/bash", "--login", "-c"]

# 创建conda环境
RUN conda create -n rospy3 python=3.7 -y && \
    conda activate rospy3                && \
    pip install empy                     && \
    pip install numpy                    && \
    pip install scipy                    && \    
    pip install pyyaml                   && \
    pip install catkin_pkg               && \
    pip install rospkg                   && \
    pip install pybind11                 && \
    pip install scikit-learn             && \
    pip install matplotlib               && \
    pip install cython                   && \
    pip install opencv-python            && \
    pip install open3d                      

# 安装pytorch
RUN cd ~/opt && \
    wget https://download.pytorch.org/whl/cu111/torch-1.9.1%2Bcu111-cp37-cp37m-linux_x86_64.whl && \
    wget https://download.pytorch.org/whl/cu111/torchvision-0.10.1%2Bcu111-cp37-cp37m-linux_x86_64.whl && \
    pip install torch-1.9.1+cu111-cp37-cp37m-linux_x86_64.whl && \
    pip install torchvision-0.10.1+cu111-cp37-cp37m-linux_x86_64.whl

# 删除apt/lists，可以减少最终镜像大小
RUN rm -rf /var/lib/apt/lists/*