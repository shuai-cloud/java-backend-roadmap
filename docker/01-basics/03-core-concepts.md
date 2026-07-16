# Docker 核心概念详解

## 一、镜像（Image）

### 什么是镜像？
镜像是一个轻量级、独立的可执行软件包，包含运行某个软件所需的一切：代码、运行时、系统工具、系统库、设置。

### 镜像分层
Docker 镜像由多个只读层（Layer）叠加而成，每一层代表一个 Dockerfile 指令。分层的好处：
- **复用**：多个镜像共享相同的基础层，节省磁盘空间。
- **缓存**：构建时，如果某一层没有变化，直接使用缓存。
┌─────────────────────────┐

│   上层：应用代码         │

├─────────────────────────┤

│   中层：依赖库           │

├─────────────────────────┤

│   基础层：Ubuntu/Alpine  │

└─────────────────────────┘

### 常用镜像命令

bash

docker images                    # 列出本地镜像

docker pull nginx:latest         # 拉取镜像

docker rmi nginx                 # 删除镜像

docker tag nginx my-nginx:v1     # 标记镜像

docker save -o nginx.tar nginx   # 导出镜像

docker load -i nginx.tar         # 导入镜像

---

## 二、容器（Container）

### 什么是容器？
容器是镜像的运行实例。它可以被启动、停止、删除、暂停。每个容器相互隔离，拥有自己的文件系统、网络、进程空间。

### 容器生命周期

镜像 → docker create → 创建容器 → docker start → 运行中 → docker stop → 停止 → docker rm → 删除

↑                                          ↓

docker run（创建+启动）                   docker restart（重启）

### 常用容器命令

bash

docker run -d --name my-nginx -p 8080:80 nginx    # 运行容器

docker ps                                           # 查看运行中容器

docker ps -a                                        # 查看所有容器

docker stop my-nginx                                # 停止容器

docker start my-nginx                               # 启动已停止的容器

docker restart my-nginx                             # 重启容器

docker rm my-nginx                                  # 删除容器

docker logs -f my-nginx                             # 查看日志

docker exec -it my-nginx /bin/bash                  # 进入容器

---

## 三、仓库（Registry）

### 什么是仓库？
仓库用于存储和分发 Docker 镜像。默认公共仓库是 **Docker Hub**，你也可以搭建私有仓库（如 Harbor、Nexus）。

### 推送镜像到 Docker Hub

bash

docker login                         # 登录

docker tag my-app:latest username/my-app:v1

docker push username/my-app:v1

### 搭建私有仓库

bash

docker run -d -p 5000:5000 --name registry registry:2

docker tag my-app:latest localhost:5000/my-app:v1

docker push localhost:5000/my-app:v1

---

## 四、Dockerfile

Dockerfile 是一个文本文件，包含构建镜像的指令。示例：

dockerfile

FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/app.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]

构建：

bash

docker build -t my-app:latest .

---

## 五、数据卷（Volume）

数据卷用于持久化容器数据，独立于容器生命周期。

bash

docker volume create my-volume

docker run -v my-volume:/data nginx

---

## 六、网络（Network）

Docker 提供多种网络模式：bridge（默认）、host、none、overlay（Swarm）。

bash

docker network create my-network

docker run --network my-network nginx

---

## 小结

- 镜像：只读模板，分层结构。
- 容器：镜像的运行实例，可读写。
- 仓库：存储分发镜像。
- Dockerfile：构建镜像的脚本。
- 数据卷：持久化数据。
- 网络：容器间通信。
