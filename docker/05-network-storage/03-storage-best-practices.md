# 存储最佳实践

## 一、选择正确的存储类型

| 场景 | 推荐方式 | 理由 |
|------|----------|------|
| 数据库数据（MySQL、PostgreSQL） | 命名卷 | 持久化、备份方便、性能好 |
| 日志文件 | 命名卷 或 Bind Mount | 方便日志采集工具读取 |
| 配置文件 | Bind Mount（只读） | 方便修改，无需重建镜像 |
| 开发时代码热更新 | Bind Mount | 宿主机代码变化即时反映到容器 |
| 缓存数据 | tmpfs | 速度快，重启即清 |
| 敏感信息（密码、密钥） | tmpfs 或 Secret（Swarm） | 不在磁盘落盘 |

---

## 二、生产环境存储建议

### 1. 始终使用命名卷
yaml

services:

db:

image: mysql:8.0

volumes:

mysql-data:/var/lib/mysql

volumes:

mysql-data:

- 避免使用 Bind Mount 挂载宿主机路径到数据库目录，可能导致权限问题。
- 命名卷由 Docker 管理，备份和迁移更容易。

### 2. 配置卷驱动
对于集群环境，使用支持 NFS、Ceph、AWS EBS 等的卷驱动，实现数据共享和高可用。

### 3. 限制卷大小
bash

docker volume create --driver local \

--opt type=tmpfs \

--opt device=tmpfs \

--opt o=size=100m \

limited-volume

### 4. 定期备份
bash

每天凌晨备份
0 3 * * * docker run --rm -v mysql-data:/data -v /backup:/backup alpine tar czf /backup/mysql-$(date +%Y%m%d).tar.gz -C /data .

---

## 三、开发环境存储建议

### 1. 使用 Bind Mount 实现热重载
yaml

services:

app:

build: .

volumes:

./src:/app/src        # 代码热更新

./config:/app/config:ro  # 配置文件

### 2. 使用 `.dockerignore` 排除不需要挂载的目录
dockerignore

node_modules

.git

target

*.log

### 3. 使用 `:cached` 或 `:delegated` 优化性能（Mac）
yaml

volumes:

./src:/app/src:cached

- `consistent`：默认，严格一致性。
- `cached`：宿主机写入优先，容器内稍后可见。
- `delegated`：容器内写入优先，宿主机稍后可见。

---

## 四、安全最佳实践

### 1. 避免挂载敏感路径
不要将宿主机的 `/etc`、`/var/run/docker.sock` 等敏感路径挂载到容器，除非必要（如监控容器）。

### 2. 使用只读挂载
yaml

volumes:

./config:/app/config:ro

### 3. 限制容器用户权限
dockerfile

RUN groupadd -r appuser && useradd -r -g appuser -u 1000 appuser

USER appuser

### 4. 使用 tmpfs 存储敏感数据
bash

docker run -d --tmpfs /tmp:size=100M my-app

---

## 五、性能优化

### 1. 数据库使用命名卷而非 Bind Mount
Bind Mount 在 Mac/Windows 上性能较差（文件共享层开销）。命名卷使用 Linux 原生文件系统，性能更好。

### 2. 避免大量小文件挂载
大量小文件的 Bind Mount 会导致性能下降，考虑将静态资源打包到镜像中。

### 3. 使用 `--storage-opt` 限制卷大小
bash

docker run -d --storage-opt size=10G mysql:8.0

### 4. 监控磁盘使用
bash

docker system df

docker system df -v   # 详细查看每个卷的大小

---

## 六、常见问题排查

### 权限问题
bash

容器内文件属主是 root，宿主机无法删除
解决方法：创建容器时指定用户 UID
docker run -d --user 1000:1000 -v data:/app/data my-app

### 挂载目录为空
- 检查宿主机路径是否存在。
- 检查容器内目标路径是否被镜像中的文件占用（Bind Mount 会覆盖容器内原有内容）。

### 卷无法删除
bash

查看哪些容器在使用卷
docker ps -a --filter volume=my-volume

强制删除卷（先删除使用它的容器）
docker volume rm -f my-volume

---

## 小结

- 生产环境用命名卷，开发环境用 Bind Mount。
- 注意权限和安全性，避免挂载敏感路径。
- 数据库等 I/O 密集型应用使用命名卷，性能更好。
- 定期备份和监控磁盘使用。