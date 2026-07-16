# Docker 网络模式详解

## 一、网络基础

Docker 容器默认使用桥接网络（bridge），容器间通过 IP 通信，但与外界隔离。Docker 提供了多种网络模式，满足不同场景需求。

## 二、五大网络模式

| 网络模式 | 命令参数 | 说明 | 适用场景 |
|----------|----------|------|----------|
| **bridge** | `--network bridge` | 默认模式，容器使用虚拟网桥，分配独立 IP | 单机容器间通信 |
| **host** | `--network host` | 容器直接使用宿主机网络栈，不隔离 | 性能敏感场景 |
| **none** | `--network none` | 容器无网络，完全隔离 | 安全沙箱、离线任务 |
| **container** | `--network container:NAME` | 共享另一个容器的网络栈 | Sidecar 模式、监控代理 |
| **overlay** | `--network overlay` | 跨主机容器通信（Swarm 模式） | 多机集群 |

---

## 三、Bridge 网络（默认）

### 工作原理
- Docker 创建一个虚拟网桥 `docker0`（默认 172.17.0.0/16）。
- 每个容器分配一个 veth pair，一端在容器内（eth0），另一端连到 `docker0`。
- 容器通过 NAT 访问外网，外网无法直接访问容器（需端口映射）。

### 自定义 Bridge 网络

bash

创建自定义桥接网络

docker network create --driver bridge --subnet 172.20.0.0/16 my-net

运行容器并连接到自定义网络

docker run -d --name web --network my-net nginx

docker run -d --name app --network my-net my-app

自定义网络中的容器可以通过服务名互相 ping 通

docker exec web ping app

### 默认 Bridge vs 自定义 Bridge
| 特性 | 默认 bridge | 自定义 bridge |
|------|-------------|---------------|
| DNS 解析 | 不支持容器名解析 | 支持容器名解析 |
| 网络隔离 | 所有容器在同一网络 | 可以创建多个隔离网络 |
| 端口映射 | 需要 -p 暴露 | 同样需要 -p |
| 动态连接 | 运行中容器可连接/断开 | 同样支持 |

---

## 四、Host 网络

bash

docker run -d --network host nginx

- 容器直接使用宿主机网络栈，没有独立 IP。
- 端口直接暴露在宿主机上，无需 `-p` 映射。
- 性能最好（无 NAT 转换），但隔离性差（端口冲突风险）。

### 适用场景
- 对网络性能要求极高的应用（如反向代理、负载均衡器）。
- 需要监听大量端口的应用。
- 容器数量少，端口规划清晰的场景。

---

## 五、None 网络

bash

docker run -d --network none alpine sleep 3600

- 容器没有网络接口，只有 loopback（127.0.0.1）。
- 完全隔离，无法访问外网，也无法被访问。

### 适用场景
- 安全敏感的离线计算任务。
- 只需要本地 socket 通信的应用。
- 测试网络隔离性。

---

## 六、Container 网络

bash

先启动一个容器

docker run -d --name sidecar --network host my-sidecar

另一个容器共享其网络

docker run -d --network container:sidecar my-app

- 两个容器共享同一个网络栈（IP、端口、hostname 相同）。
- 它们之间的通信通过 localhost 进行。

### 适用场景
- Sidecar 模式：主容器 + 日志收集/监控代理。
- 需要共享端口的场景（如 Istio Envoy + 应用容器）。

---

## 七、Overlay 网络（Swarm 模式）

bash

初始化 Swarm

docker swarm init

创建 overlay 网络

docker network create --driver overlay --attachable my-overlay

在服务中使用

docker service create --name web --network my-overlay nginx

- 跨主机容器通信，封装在 VXLAN 隧道中。
- 需要 Swarm 模式或 Docker EE。

---

## 八、端口映射与暴露

bash

随机映射宿主机端口到容器 80 端口

docker run -d -p 80 nginx

指定宿主机端口

docker run -d -p 8080:80 nginx

指定 IP 和端口

docker run -d -p 192.168.1.100:8080:80 nginx

UDP 端口

docker run -d -p 53:53/udp dns-server

多端口映射

docker run -d -p 8080:80 -p 443:443 nginx

### 查看端口映射

bash

docker port my-nginx

输出：80/tcp -> 0.0.0.0:8080
---

## 九、网络故障排查

bash

查看网络列表

docker network ls

查看网络详情（连接的容器、IP 等）

docker network inspect my-net

查看容器网络配置

docker inspect my-nginx | grep -A 20 "NetworkSettings"

进入容器测试连通性

docker exec -it my-nginx ping other-container

查看 iptables 规则（Linux）

iptables -t nat -L -n

---

## 小结

- 默认 bridge 适合单机容器通信，自定义 bridge 支持 DNS 解析。
- host 模式性能好但隔离差，none 模式完全隔离。
- container 模式适合 Sidecar，overlay 用于跨主机。
- 端口映射是容器对外暴露的唯一方式（除 host 模式）。