# Docker配置ros+cuda+pytorch镜像
Docker tutorial for ros+cuda+pytorch 

## 1. 在本机上安装Ubuntu18.04的系统

## 2. 在本机上安装Nvidia Driver,Cuda和Cudnn
[安装教程](https://blog.csdn.net/i6101206007/article/details/113179852)

## 3. 在本机上安装Docker
```shell
# 在Ubuntu系统安装docker
cat <<"EOF" | bash                              
sudo apt update && \
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y && \
sudo apt-get remove docker docker.io containerd runc -y && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
sudo apt update && \
sudo apt install docker-ce docker-ce-cli containerd.io -y
EOF
# 检查Docker服务的状态来以验证Docker是否正确的安装
sudo systemctl status docker 
```

## 4. 在本机上安装NVIDIA Container Toolkit
```sh
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# 安装nvidia-docker2
sudo apt-get update
sudo apt-get install -y nvidia-docker2

# 重启docker
sudo systemctl restart docker

# 测试是否安装成功
docker run --rm --gpus all nvidia/cuda:11.3.0-base nvidia-smi
```

## 5. 从dockerhub上下载镜像
```sh
# 下载镜像
docker pull nvidia/cuda:11.1.1-cudnn8-runtime-ubuntu18.04
```

## 6. 制作镜像
```sh
# 写入Dockerfile
# 制作镜像
docker build -f center.Dockerfile -t center:latest .
```