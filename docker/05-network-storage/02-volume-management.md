# Docker 数据卷管理

## 一、为什么需要数据卷？

容器默认的文件系统是临时的，容器删除后数据丢失。数据卷（Volume）提供了持久化存储，独立于容器生命周期。

## 二、三种挂载方式

| 方式 | 存储位置 | 管理方式 | 适用场景 |
|------|----------|----------|----------|
| **Volume（命名卷）** | `/var/lib/docker/volumes/` | Docker 管理 | 生产环境持久化数据 |
| **Bind Mount（绑定挂载）** | 宿主机任意路径 | 用户管理 | 开发热更新、配置文件 |
| **tmpfs mount** | 内存 | 临时 | 敏感数据、缓存 |

---

## 三、Volume（命名卷）

### 创建和使用
bash

创建卷
docker volume create my-volume

查看卷
docker volume ls

docker volume inspect my-volume

挂载卷到容器
docker run -d --name db -v my-volume:/var/lib/mysql mysql:8.0

删除卷（必须先停止使用它的容器）
docker volume rm my-volume

清理未使用的卷
docker volume prune

### 在 Docker Compose 中使用
yaml

services:

db:

image: mysql:8.0

volumes:

mysql-data:/var/lib/mysql

volumes:

mysql-data:

### 卷驱动
bash

使用 NFS 卷驱动
docker volume create --driver local \

--opt type=nfs \

--opt o=addr=192.168.1.100,rw \

--opt device=:/shared/path \

nfs-volume

---

## 四、Bind Mount（绑定挂载）
bash

挂载宿主机目录到容器
docker run -d --name web -v /host/path:/container/path nginx

只读挂载
docker run -d --name web -v /host/config:/etc/nginx/conf.d:ro nginx

挂载单个文件
docker run -d --name web -v /host/nginx.conf:/etc/nginx/nginx.conf:ro nginx

### 在 Docker Compose 中使用
yaml

services:

web:

image: nginx

volumes:

./html:/usr/share/nginx/html       # 相对路径

/absolute/path/config:/etc/nginx/conf.d:ro  # 绝对路径

### 注意事项
- 宿主机路径必须存在，否则 Docker 会创建目录（而非文件）。
- 文件挂载时，宿主机文件必须存在。
- 权限问题：容器内用户需要有对应权限。

---

## 五、tmpfs 挂载
bash

挂载 tmpfs（内存）
docker run -d --name cache --tmpfs /cache:size=100M nginx

或使用 --mount
docker run -d --name cache --mount type=tmpfs,destination=/cache,tmpfs-size=100M nginx

### 特点
- 数据存储在内存中，速度快。
- 容器停止后数据丢失。
- 适合存储临时文件、敏感信息（密码、密钥）。

---

## 六、--mount 语法（推荐）

Docker 17.06+ 推荐使用 `--mount` 替代 `-v`，语法更清晰：
bash

Volume
docker run -d --name db \

--mount source=my-volume,target=/var/lib/mysql \

mysql:8.0

Bind Mount
docker run -d --name web \

--mount type=bind,source=/host/html,target=/usr/share/nginx/html,readonly \

nginx

tmpfs
docker run -d --name cache \

--mount type=tmpfs,destination=/cache,tmpfs-size=100M \

nginx

---

## 七、备份与恢复

### 备份卷数据
bash

启动临时容器，挂载卷并打包
docker run --rm -v my-volume:/data -v /backup:/backup alpine \

tar czf /backup/my-volume-backup.tar.gz -C /data .

### 恢复卷数据
bash

先创建卷
docker volume create my-volume

启动临时容器解压
docker run --rm -v my-volume:/data -v /backup:/backup alpine \

tar xzf /backup/my-volume-backup.tar.gz -C /data

---

## 八、权限管理

容器内进程以 root 运行时会创建 root 属主的文件，导致宿主机无法删除。解决方案：
bash

在 Dockerfile 中创建用户并指定 UID
RUN groupadd -r appuser && useradd -r -g appuser -u 1000 appuser

USER appuser

运行时指定用户
docker run -d --user 1000:1000 -v data:/app/data my-app

---

## 小结

- Volume 是生产环境首选的持久化方式，Docker 管理，备份方便。
- Bind Mount 适合开发热更新和配置文件挂载。
- tmpfs 适合临时敏感数据。
- 推荐使用 `--mount` 语法，更清晰。
- 注意容器用户权限，避免文件归属问题。