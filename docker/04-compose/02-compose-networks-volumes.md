# Compose 中的网络与数据卷

## 一、网络

### 默认网络
如果不显式定义网络，Compose 会创建一个默认网络，所有服务都在该网络中，可以通过服务名互相访问。

### 自定义网络
yaml

services:

web:

image: nginx

networks:

frontend

backend

api:

image: my-api

networks:

backend

db:

image: mysql

networks:

backend

networks:

frontend:

backend:

- `web` 可以访问 `api` 和 `db`（都在 `backend` 网络）。
- `web` 对外暴露端口（通过 `ports`），内部通过 `backend` 网络调用 `api`。
- 网络隔离：`frontend` 和 `backend` 是两个独立网络，只有同时在两个网络中的服务才能跨网络通信。

### 网络驱动
yaml

networks:

my-net:

driver: bridge        # 默认，单机

# driver: overlay     # Swarm 模式，跨主机

# driver: host        # 使用宿主机网络

### 配置静态 IP
yaml

services:

db:

image: mysql

networks:

backend:

ipv4_address: 172.20.0.10

networks:

backend:

ipam:

config:

subnet: 172.20.0.0/16

---

## 二、数据卷

### 命名卷（推荐）
yaml

services:

db:

image: mysql:8.0

volumes:

mysql-data:/var/lib/mysql

volumes:

mysql-data:               # 声明命名卷

命名卷由 Docker 管理，存储在宿主机特定目录（`/var/lib/docker/volumes/`），备份和迁移更方便。

### 绑定挂载（Bind Mount）
yaml

services:

web:

image: nginx

volumes:

./html:/usr/share/nginx/html   # 宿主目录:容器目录

./nginx.conf:/etc/nginx/nginx.conf:ro   # 只读挂载

适合开发时热更新代码，或挂载配置文件。

### 匿名卷
yaml

volumes:

/var/lib/mysql   # 不指定名称，Docker 随机生成名字

不推荐，因为难以管理。

### 卷的权限
yaml

services:

app:

image: my-app

volumes:

data:/app/data

user: "1000:1000"   # 指定容器内用户 UID/GID，避免权限问题

volumes:

data:

### 卷驱动
yaml

volumes:

my-volume:

driver: local

driver_opts:

type: none

device: /path/on/host

o: bind

---

## 三、综合示例
yaml

version: '3.8'

services:

app:

build: .

ports:

"8080:8080"

volumes:

./src:/app/src          # 开发时热重载

./config:/app/config:ro # 配置文件只读挂载

networks:

internal

depends_on:

db

db:

image: postgres:15

environment:

POSTGRES_PASSWORD: secret

volumes:

pg-data:/var/lib/postgresql/data

./init.sql:/docker-entrypoint-initdb.d/init.sql  # 初始化脚本

networks:

internal:

ipv4_address: 172.20.0.5

redis:

image: redis:7-alpine

volumes:

redis-data:/data

networks:

internal

networks:

internal:

ipam:

config:

subnet: 172.20.0.0/24

volumes:

pg-data:

redis-data:

---

## 小结

- 网络：自定义网络实现服务间通信和隔离，支持静态 IP。
- 数据卷：命名卷适合持久化数据，绑定挂载适合开发热更新。
- 生产环境推荐命名卷，结合备份策略。
- 注意容器内用户权限，避免挂载目录无法写入。