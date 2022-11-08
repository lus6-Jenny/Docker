# 配置多机SLAM的docker镜像
Docker tutorial for ros+cuda+python3 

## 1. 在本机上安装ubuntu18.04的系统

## 2. 在本机上安装cuda和cudnn
[安装教程](https://blog.csdn.net/i6101206007/article/details/113179852)

## 3. 在本机上安装docker
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

## 4. 在本机上安装nvidia-docker2
```sh
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker

# 验证nvidia-docker2是否安装成功
docker run --rm --gpus all nvidia/cuda:11.3.0-base nvidia-smi
```

## 5. 