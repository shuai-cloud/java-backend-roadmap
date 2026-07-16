# 镜像管理

## 一、镜像是什么？

镜像是容器的只读模板，包含运行应用所需的文件系统、依赖、配置。镜像由多层（Layer）叠加而成，每一层对应 Dockerfile 中的一条指令。分层的好处是复用和缓存。

## 二、拉取与推送

### 拉取镜像
bash

从 Docker Hub 拉取
docker pull nginx:latest

从私有仓库拉取
docker pull registry.example.com/my-app:v1

指定平台（如 arm64）
docker pull --platform linux/amd64 nginx

### 推送镜像
bash

先登录
docker login

标记镜像（tag）
docker tag my-app:latest username/my-app:v1

推送
docker push username/my-app:v1

推送到私有仓库
docker tag my-app:latest registry.example.com/my-app:v1

docker push registry.example.com/my-app:v1

## 三、导出与导入

### 导出镜像为 tar 文件
bash

docker save -o nginx.tar nginx:latest

### 从 tar 文件导入镜像
bash

docker load -i nginx.tar

### 导出/导入容器快照（export/import，会丢失历史层）
bash

docker export -o container.tar my-container

docker import container.tar my-image:new

## 四、查看与管理
bash

列出本地镜像
docker images

查看镜像详细信息
docker inspect nginx:latest

查看镜像分层历史
docker history nginx:latest

搜索镜像
docker search nginx

删除镜像
docker rmi nginx:latest

强制删除
docker rmi -f nginx:latest

删除所有未使用的镜像（悬空镜像）
docker image prune

删除所有未被容器使用的镜像
docker image prune -a

## 五、镜像分层原理

Docker 镜像由多个只读层组成，每层代表一个 Dockerfile 指令。例如：
dockerfile

FROM ubuntu:22.04          # 层1：基础层

RUN apt-get update && apt-get install -y python3  # 层2：安装依赖

COPY app.py /app/          # 层3：复制文件

CMD ["python3", "/app/app.py"]  # 层4：元数据（不占层）

构建时，如果某层没有变化，Docker 会使用缓存层，加快构建速度。

## 六、常见问题

### 镜像占用磁盘空间太大怎么办？
- 使用 Alpine 基础镜像（如 `openjdk:17-jdk-alpine`）。
- 多阶段构建，只保留最终产物。
- 定期清理未使用的镜像：`docker image prune -a`。

### 如何查看镜像的层？
bash

docker history nginx:latest

### 如何修改镜像标签？
bash

docker tag old-image:old-tag new-image:new-tag

---

## 小结

- 镜像管理包括拉取、推送、导出、导入、删除、清理。
- 理解分层原理有助于优化镜像大小和构建速度。
- 定期清理无用镜像，节省磁盘空间。