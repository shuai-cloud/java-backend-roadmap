# Docker 安装与配置

## 一、Windows / Mac

推荐安装 **Docker Desktop**，自带 Docker Engine、Docker CLI、Docker Compose、Kubernetes。

1. 访问 [Docker Desktop 官网](https://www.docker.com/products/docker-desktop/) 下载安装包。
2. 双击安装，根据向导完成。
3. 启动后，终端验证：
   bash

docker version

docker run hello-world

---

## 二、Linux（Ubuntu）

bash

卸载旧版本

sudo apt-get remove docker docker-engine docker.io containerd runc

安装依赖

sudo apt-get update

sudo apt-get install ca-certificates curl gnupg lsb-release

添加 Docker 官方 GPG 密钥

curl -fsSL https://download.docker.com/linux/ubuntu/gpg
| sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

设置稳定版仓库

echo "deb [arch=(dpkg−−print−architecture)signed−by=/usr/share/keyrings/docker−archive−keyring.gpg]https://download.docker.com/linux/ubuntu(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

安装 Docker Engine

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

启动并设置开机自启

sudo systemctl start docker

sudo systemctl enable docker

验证

sudo docker run hello-world

### 非 root 用户执行 docker 命令

bash

sudo usermod -aG docker $USER

重新登录或执行 newgrp docker
---

## 三、验证安装

bash

docker version

docker info

docker run hello-world

---

## 四、配置镜像加速器（国内）

编辑 `/etc/docker/daemon.json`（Linux）或 Docker Desktop 设置中配置：

json

{

"registry-mirrors": [

"https://docker.mirrors.ustc.edu.cn
",

"https://hub-mirror.c.163.com
"

]

}

重启 Docker：

bash

sudo systemctl daemon-reload

sudo systemctl restart docker

---

## 小结

- Windows/Mac 推荐 Docker Desktop。
- Linux 通过包管理器安装，注意添加用户到 docker 组。
- 国内用户配置镜像加速器，提升拉取速度。