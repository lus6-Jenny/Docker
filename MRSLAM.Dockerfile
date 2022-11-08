FROM osrf/ros:melodic-desktop-full

# 设置环境变量
ENV DEBIAN_FRONTEND noninteractive

# 用root用户安装依赖
USER root 

# 更换阿里云源，在国内可以加快速度
RUN sed -i "s/security.ubuntu.com/mirrors.aliyun.com/" /etc/apt/sources.list && \
    sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/" /etc/apt/sources.list && \
    sed -i "s/security-cdn.ubuntu.com/mirrors.aliyun.com/" /etc/apt/sources.list
RUN  apt-get clean

### nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub

# 更新源，安装相应工具
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    gdb \
    net-tools \
    git \
    vim \
    wget \
    curl \
    zip \
    unzip \
    htop \
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
    pip install python-intervals==1.10.0.post1      && \
    pip install opencv-python==4.3.0.36             && \
    pip install open3d==0.8.0.0                     && \
    pip install tensorboardX==2.1                   && \
    pip install tensorboard==2.4.1                  && \
    pip install psutil==5.8.0                       

# 安装pytorch
RUN cd ~/opt && \
    wget https://download.pytorch.org/whl/cu111/torch-1.9.1%2Bcu111-cp37-cp37m-linux_x86_64.whl && \
    wget https://download.pytorch.org/whl/cu111/torchvision-0.10.1%2Bcu111-cp37-cp37m-linux_x86_64.whl && \
    pip install torch-1.9.1+cu111-cp37-cp37m-linux_x86_64.whl && \
    pip install torchvision-0.10.1+cu111-cp37-cp37m-linux_x86_64.whl

# 删除apt/lists，可以减少最终镜像大小
RUN rm -rf /var/lib/apt/lists/*