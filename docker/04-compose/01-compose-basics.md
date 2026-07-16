# Docker Compose 基础

## 一、什么是 Docker Compose？

Docker Compose 是一个用于定义和运行多容器 Docker 应用的工具。通过一个 `docker-compose.yml` 文件，你可以一次性配置所有服务的镜像、端口、卷、网络、环境变量等，然后使用一条命令启动整个应用栈。

### 优势
- **声明式配置**：所有服务定义在一个文件中，可版本化管理。
- **一键启停**：`docker compose up` 启动所有服务，`docker compose down` 停止并清理。
- **环境隔离**：每个项目默认创建独立的网络，避免冲突。
- **开发效率高**：快速搭建本地开发环境（如 Spring Boot + MySQL + Redis）。

---

## 二、安装

Docker Desktop 已自带 Compose V2（`docker compose` 命令）。Linux 上单独安装：
bash

下载最新版
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-(uname−s)−(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

验证
docker compose version

---

## 三、基本结构
yaml

version: '3.8'          # Compose 文件版本（通常用 3.8）

services:               # 定义各个服务

web:                  # 服务名称

image: nginx:latest

ports:

"8080:80"

volumes:

./html:/usr/share/nginx/html

networks:

frontend

app:                  # 第二个服务

build: .            # 使用当前目录的 Dockerfile 构建

ports:

"3000:3000"

depends_on:

db

db:

image: mysql:8.0

environment:

MYSQL_ROOT_PASSWORD: rootpass

volumes:

mysql-data:/var/lib/mysql

networks:

backend

networks:               # 定义网络

frontend:

backend:

volumes:                # 定义数据卷

mysql-data:

---

## 四、常用命令
bash

启动所有服务（前台，日志实时输出）
docker compose up

后台启动
docker compose up -d

停止所有服务
docker compose down

停止并删除卷（慎用，会丢失数据）
docker compose down -v

查看运行中的服务
docker compose ps

查看日志
docker compose logs -f

查看某个服务的日志
docker compose logs -f web

重新构建镜像并启动
docker compose up -d --build

执行命令到某个服务
docker compose exec app bash

重启某个服务
docker compose restart web

暂停/恢复服务
docker compose pause web

docker compose unpause web

查看服务配置
docker compose config

---

## 五、一个完整的 Web 应用示例
yaml

version: '3.8'

services:

redis:

image: redis:7-alpine

ports:

"6379:6379"

volumes:

redis-data:/data

restart: unless-stopped

mysql:

image: mysql:8.0

environment:

MYSQL_ROOT_PASSWORD: root123

MYSQL_DATABASE: myapp

ports:

"3306:3306"

volumes:

mysql-data:/var/lib/mysql

restart: unless-stopped

app:

build:

context: .

dockerfile: Dockerfile

ports:

"8080:8080"

environment:

SPRING_PROFILES_ACTIVE: dev

DB_HOST: mysql

DB_PORT: 3306

REDIS_HOST: redis

depends_on:

mysql

redis

restart: unless-stopped

volumes:

redis-data:

mysql-data:

---

## 小结

- Docker Compose 通过 `docker-compose.yml` 定义多容器应用。
- 常用命令：`up`、`down`、`logs`、`exec`、`ps`。
- `depends_on` 控制启动顺序，但不等待服务完全就绪（需要额外 healthcheck）。
- 数据卷和网络在文件末尾声明。