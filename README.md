# Docker配置ros+cuda+pytorch镜像
Docker tutorial for ros+cuda+pytorch 

## 1. 在本机上安装Ubuntu18.04的系统

## 2. 在本机上安装NVIDIA Driver, Cuda和Cudnn
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
# 使用Dockerfile制作镜像
docker build -f center.Dockerfile -t center:0.0.1 .
```

## 7. 运行镜像
```sh
# 运行镜像
docker run -it --rm --gpus all --net=host --name center center:0.0.1 
# 进入容器
docker exec -it center bash
```

## 8. 保存镜像
```sh
# 保存镜像
docker save -o center.tar center:0.0.1
# 上传镜像到dockerhub
docker login
docker tag center:0.0.1 lusha/center:0.0.1
docker push lusha/center:0.0.1
# 传输镜像
scp center.tar
# 加载镜像
docker load -i center.tar
# 下载镜像
docker pull lusha/center:0.0.1
```

## 9. docker设置ip
```sh
# 查看docker0的ip
ifconfig docker0
# 设置docker0的ip
sudo ifconfig docker0
```