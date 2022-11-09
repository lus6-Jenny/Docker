# 在pytorch基础镜像里面安装ros
FROM pytorch/pytorch:1.12.1-cuda11.3-cudnn8-runtime

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
# RUN apt-get clean

# GPG key (cuda & machine-learning)
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub && \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub

# 安装ros-melodic-desktop-full
RUN apt-get update && apt-get install -y lsb-release gnupg2

# RUN RUN sh -c '. /etc/lsb-release && echo "deb http://mirrors.tuna.tsinghua.edu.cn/ros/ubuntu/ `lsb_release -cs` main" > /etc/apt/sources.list.d/ros-latest.list'
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN apt-get update && \
    apt-get install -y ros-melodic-desktop-full && \
    apt-get install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential && \
    echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc && \
    apt-get -y update --fix-missing && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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

# 清除缓存，减小镜像体积
RUN rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/archives/*

# 创建nx用户
RUN adduser --disabled-password --gecos '' nx && \
    adduser nx sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# 为nx用户安装依赖
USER nx
WORKDIR /home/nx
CMD /bin/bash

# bashrc
RUN echo "alias condaa='conda activate'" >> ~/.bashrc && \
    echo "alias condad='conda deactivate'" >> ~/.bashrc && \
    echo "alias sdb='source devel/setup.bash'" >> ~/.bashrc && \
    echo "" >> ~/bashrc.sh && \
    # echo "export ROS_MASTER_URI=http://localhost:11311" >> ~/bashrc.sh && \
    # echo "export ROS_HOSTNAME=localhost" >> ~/bashrc.sh && \
    # echo "export ROS_IP=localhost" >> ~/bashrc.sh && \
    # echo "export ROSLAUNCH_SSH_UNKNOWN=1" >> ~/bashrc.sh && \
    # echo "export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:/home/nx/catkin_ws/src" >> ~/bashrc.sh && \
    # echo "export ROS_WORKSPACE=/home/nx/catkin_ws" >> ~/bashrc.sh && \
    # echo "export ROS_PYTHON_VERSION=3" >> ~/bashrc.sh && \
    # echo "export PYTHONPATH=$PYTHONPATH:/home/nx/catkin_ws/devel/lib/python3/dist-packages" >> ~/bashrc.sh && \
    echo "source ~/bashrc.sh" >> ~/.bashrc

# tmux config
RUN echo "set -g prefix C-x" >> ~/.tmux.conf && \
    echo "unbind C-b" >> ~/.tmux.conf && \
    echo "bind C-x send-prefix" >> ~/.tmux.conf && \
    echo "set -g mouse on" >> ~/.tmux.conf

SHELL ["/bin/bash", "-c"]

# 解决pip安装超时问题
# · pip --default-timeout=1000 install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt
# · pip更换阿里云源
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple && \
    pip config set install.trusted-host mirrors.aliyun.com

# 安装依赖 
RUN pip install empy                     && \
    pip install numpy                    && \
    pip install scipy                    && \    
    pip install pyyaml                   && \
    pip install catkin_pkg               && \
    pip install rospkg                   && \
    pip install pybind11                 && \
    pip install setuptools               && \
    pip install scikit-learn             && \
    pip install matplotlib               && \
    pip install cython                   && \
    pip install opencv-python            && \
    pip install open3d                      
