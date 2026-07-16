# Docker 常用命令速查

## 一、镜像管理
bash

列出本地镜像
docker images

拉取镜像
docker pull ubuntu:22.04

搜索镜像
docker search nginx

删除镜像
docker rmi nginx:latest

标记镜像
docker tag nginx:latest my-nginx:v1

导出镜像到 tar 文件
docker save -o nginx.tar nginx:latest

从 tar 文件导入镜像
docker load -i nginx.tar

查看镜像历史
docker history nginx:latest

---

## 二、容器生命周期
bash

创建并启动容器（前台）
docker run nginx

创建并启动容器（后台）
docker run -d --name my-nginx nginx

映射端口
docker run -d -p 8080:80 nginx

挂载数据卷
docker run -d -v /host/path:/container/path nginx

设置环境变量
docker run -d -e ENV=production nginx

限制资源
docker run -d --memory=512m --cpus=1 nginx

列出运行中容器
docker ps

列出所有容器（包括停止的）
docker ps -a

停止容器
docker stop my-nginx

启动已停止的容器
docker start my-nginx

重启容器
docker restart my-nginx

暂停容器
docker pause my-nginx

恢复暂停的容器
docker unpause my-nginx

删除容器
docker rm my-nginx

强制删除运行中的容器
docker rm -f my-nginx

查看容器日志
docker logs my-nginx

实时查看日志
docker logs -f my-nginx

进入容器交互终端
docker exec -it my-nginx /bin/bash

查看容器进程
docker top my-nginx

查看容器详细信息（JSON）
docker inspect my-nginx

查看容器资源使用
docker stats my-nginx

---

## 三、网络
bash

列出网络
docker network ls

创建网络
docker network create my-net

连接容器到网络
docker network connect my-net my-nginx

断开容器与网络的连接
docker network disconnect my-net my-nginx

查看网络详情
docker network inspect my-net

删除网络
docker network rm my-net

---

## 四、数据卷
bash

列出数据卷
docker volume ls

创建数据卷
docker volume create my-vol

查看数据卷详情
docker volume inspect my-vol

删除数据卷
docker volume rm my-vol

清理未使用的数据卷
docker volume prune

---

## 五、Docker Compose
bash

启动所有服务（后台）
docker compose up -d

停止所有服务
docker compose down

查看日志
docker compose logs -f

列出服务
docker compose ps

重新构建镜像并启动
docker compose up -d --build

停止并删除容器、网络、卷
docker compose down -v

---

## 六、系统管理
bash

查看 Docker 系统信息
docker info

查看磁盘使用情况
docker system df

清理未使用的资源（容器、镜像、网络、卷）
docker system prune

清理所有未使用的资源（包括卷）
docker system prune -a --volumes

---

## 小结

- 掌握这些命令足以应对日常开发和面试。
- 多用 `--help` 查看命令详情，如 `docker run --help`。
- 生产环境注意资源限制和日志管理。
