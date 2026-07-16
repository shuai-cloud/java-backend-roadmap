# Docker 面试题精选（3-5 年经验）

> 以下题目覆盖 Docker 的核心原理、常用操作、实战经验和常见坑点。每个问题给出了“面试官想听什么”和“回答要点”。

---

## 一、基础概念

### 1. Docker 是什么？和虚拟机有什么区别？
**回答要点**：
- Docker 是一个容器化平台，将应用及其依赖打包到轻量级容器中运行。
- 区别：容器共享宿主机内核，启动秒级，资源占用 MB 级；虚拟机有独立内核，启动分钟级，资源占用 GB 级。
- 容器是进程级隔离，虚拟机是硬件级虚拟化。

### 2. 解释 Docker 的镜像分层机制。
**回答要点**：
- 镜像由多个只读层（Layer）叠加而成，每一层对应 Dockerfile 中的一条指令。
- 分层的好处：复用（多个镜像共享相同的基础层）、缓存（构建时未变化的层直接使用缓存）。
- 容器运行时在镜像层之上添加一个可写层（容器层），所有修改都在这一层，容器删除后修改消失。

### 3. Docker 的四大核心组件是什么？
**回答要点**：
- **Docker Daemon（dockerd）**：后台守护进程，管理镜像、容器、网络、数据卷。
- **Docker Client（docker）**：命令行工具，与 Daemon 通信。
- **Docker Registry**：镜像仓库，默认 Docker Hub。
- **Docker Objects**：镜像、容器、网络、数据卷等。

---

## 二、进阶原理

### 4. Docker 的网络模式有哪些？分别适用什么场景？
**回答要点**：
- **bridge**（默认）：容器通过虚拟网桥通信，适合单机容器间通信。
- **host**：容器直接使用宿主机网络栈，性能好但隔离差，适合性能敏感场景。
- **none**：无网络，完全隔离，适合安全沙箱。
- **container**：共享另一个容器的网络栈，适合 Sidecar 模式。
- **overlay**：跨主机容器通信（Swarm 模式），适合多机集群。

### 5. Docker 数据持久化的方式有哪些？
**回答要点**：
- **Volume（命名卷）**：Docker 管理，存储在 `/var/lib/docker/volumes/`，适合生产环境持久化数据。
- **Bind Mount（绑定挂载）**：挂载宿主机任意路径，适合开发热更新和配置文件。
- **tmpfs mount**：存储在内存中，容器停止后数据丢失，适合临时敏感数据。

### 6. 解释 Docker 的 CMD 和 ENTRYPOINT 的区别。
**回答要点**：
- `CMD`：提供容器启动时的默认命令，可以被 `docker run` 后面的参数覆盖。
- `ENTRYPOINT`：容器的主命令，不容易被覆盖（除非使用 `--entrypoint`）。
- 常用组合：`ENTRYPOINT` 固定可执行文件，`CMD` 提供默认参数。

### 7. 多阶段构建的作用是什么？怎么实现？
**回答要点**：
- 作用：减小最终镜像体积，只保留运行所需的产物，不包含构建工具和源码。
- 实现：在 Dockerfile 中使用多个 `FROM` 语句，每个 `FROM` 是一个阶段，通过 `COPY --from=<stage>` 从前一阶段复制文件。

### 8. Docker 的资源限制怎么做？
**回答要点**：
- 内存限制：`--memory=512m --memory-swap=512m`。
- CPU 限制：`--cpus=1.5` 或 `--cpu-shares=512`。
- 磁盘 IO 限制：`--device-read-iops`、`--device-write-bps`。
- 生产环境必须设置资源限制，防止容器争抢资源。

---

## 三、实战与排错

### 9. 容器启动后马上退出（Exited），可能的原因？
**回答要点**：
- 前台进程没有保持运行（如 `CMD` 执行完就结束）。
- 应用启动失败（端口冲突、配置错误）。
- 资源不足（OOM Kill）。
- 排查方法：`docker logs <container>` 查看日志，`docker inspect` 查看退出码。

### 10. 如何进入正在运行的容器？
**回答要点**：

bash

docker exec -it <container> /bin/bash

如果容器中没有 bash，可以用 sh

docker exec -it <container> sh

### 11. 如何查看容器的资源使用情况？
**回答要点**：

bash

docker stats                 # 实时查看所有容器

docker stats <container>     # 查看单个容器

docker inspect <container>   # 查看详细配置（包括资源限制）

### 12. 镜像构建缓慢，如何优化？
**回答要点**：
- 利用构建缓存：将变化不频繁的指令放在前面（如安装依赖），变化频繁的放在后面（如复制源代码）。
- 使用更小的基础镜像（Alpine、slim）。
- 多阶段构建，只保留最终产物。
- 合并 RUN 命令，减少层数。
- 配置镜像加速器（国内用户）。

### 13. 容器间如何通信？
**回答要点**：
- 同一自定义网络中的容器可以通过容器名（DNS）通信。
- 默认 bridge 网络需要通过 IP 通信（不推荐）。
- 不同网络间的容器可以通过连接多个网络或端口映射通信。

### 14. 如何清理 Docker 占用的磁盘空间？
**回答要点**：

bash

docker system prune                    # 清理未使用的容器、网络、镜像（悬空）

docker system prune -a                 # 清理所有未使用的镜像（包括未被引用的）

docker system prune -a --volumes       # 包括卷（慎用）

docker volume prune                    # 清理未使用的卷

### 15. 如何备份和恢复 Docker 卷？
**回答要点**：

bash

备份

docker run --rm -v my-volume:/data -v /backup:/backup alpine tar czf /backup/volume-backup.tar.gz -C /data .

恢复

docker run --rm -v my-volume:/data -v /backup:/backup alpine tar xzf /backup/volume-backup.tar.gz -C /data

---

## 四、开放性问题

### 16. 你们公司如何用 Docker 部署微服务？
**回答要点**：
- 每个微服务一个 Docker 镜像，通过 Docker Compose 或 Kubernetes 编排。
- 使用 CI/CD 流水线构建镜像并推送到私有仓库。
- 生产环境使用 Kubernetes 管理容器集群。
- 日志收集到 ELK，监控使用 Prometheus + Grafana。

### 17. Docker Compose 和 Kubernetes 的区别是什么？
**回答要点**：
- Docker Compose：单机多容器编排工具，适合开发测试环境。
- Kubernetes：生产级的容器编排平台，支持自动伸缩、服务发现、滚动更新、自愈等。
- 简单项目用 Compose，复杂生产环境用 K8s。

### 18. 如果让你设计一个容器化部署方案，你会考虑哪些因素？
**回答要点**：
- 基础镜像选择（Alpine vs Ubuntu，版本固定）。
- 镜像体积优化（多阶段构建，清理缓存）。
- 资源限制（CPU、内存）。
- 数据持久化（命名卷 vs 绑定挂载）。
- 网络规划（自定义网络，端口映射）。
- 日志和监控（集中式日志，健康检查）。
- 安全性（非 root 用户，镜像漏洞扫描）。
- 高可用（多副本，滚动更新）。

### 19. Docker 和 Podman 有什么区别？
**回答要点**：
- Podman 不需要守护进程（daemonless），更安全。
- Podman 兼容 Docker CLI 命令。
- Podman 原生支持 rootless 模式。
- 目前 Docker 仍是主流，Podman 在 Red Hat 生态中推广。

### 20. 解释 Docker 的 Copy-on-Write（写时复制）机制。
**回答要点**：
- 多个容器可以共享同一个镜像层，当容器需要修改某个文件时，Docker 将该文件从只读层复制到容器的可写层再进行修改。
- 优点：节省磁盘空间，启动速度快。
- 缺点：大量写操作时性能下降（因为需要复制）。

---

## 小结

- 面试 Docker 时，重点理解镜像分层、网络模式、数据持久化、资源限制。
- 结合实际项目经验（如用 Docker Compose 部署 Spring Boot + MySQL + Redis）回答问题更有说服力。
- 准备好一个“你们公司用 Docker 做什么”的故事，能串联起多个知识点。