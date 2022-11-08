# 在python3里使用ros

## 1. 安装miniconda

```bash
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh
```

## 2. 创建新环境并配置

```sh
conda create -n rospy3 python=3.7 -y
conda activate rospy3
conda install -c anaconda make
pip install catkin_pkg
pip install rospkg
pip install empy
pip install numpy
pip install scipy
pip install pyyaml
```

## 3. 安装sip

```sh
cd ~/miniconda3/envs/rospy3/
wget https://www.riverbankcomputing.com/static/Downloads/sip/4.19.25/sip-4.19.25.tar.gz
tar -zxvf sip-4.19.25.tar.gz
cd sip-4.19.25
python configure.py
make
make install
```

## 4. 安装orocos_kinematics_dynamics

```sh
cd ~/miniconda3/envs/rospy3/
### https://github.com/orocos/orocos_kinematics_dynamics/releases/tag/v1.4.0
### reference: https://github.com/orocos/orocos_kinematics_dynamics/blob/master/orocos_kdl/INSTALL.md
wget https://github.com/orocos/orocos_kinematics_dynamics/archive/refs/tags/v1.4.0.tar.gz
mv v1.4.0.tar.gz orocos_kinematics_dynamics-1.4.0.tar.gz
tar zxvf orocos_kinematics_dynamics-1.4.0.tar.gz
cd orocos_kinematics_dynamics-1.4.0/orocos_kdl
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=~/miniconda3/envs/rospy3
make
make install
### to uninstall: cat install_manifest.txt | sudo xargs rm
```

## 5. 下载tf和tf2

```sh
cd ~/miniconda3/envs/rospy3/
mkdir -p catkin_ws/src && cd catkin_ws/src
 
git clone -b melodic-devel https://github.com/ros/geometry.git
git clone -b melodic-devel https://github.com/ros/geometry2.git
```

## 6. 编译tf和tf2

```sh
cd ~/miniconda3/envs/rospy3/catkin_ws/
catkin_make_isolated --cmake-args \
                     -DCMAKE_BUILD_TYPE=Release \
                     -DPYTHON_EXECUTABLE=~/miniconda3/envs/rospy3/bin/python \
                     -DPYTHON_INCLUDE_DIR=~/miniconda3/envs/rospy3/include/python3.7m \
                     -DPYTHON_LIBRARY=~/miniconda3/envs/rospy3/lib/libpython3.7m.so
source ~/miniconda3/envs/rospy3/catkin_ws/devel_isolated/setup.bash                     
```

## 7. 测试

```sh
python -c 'import rospy; print(rospy)'
python -c 'import tf; print(tf)'
```