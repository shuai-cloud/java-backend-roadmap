# Nacos 集群部署

## 一、集群架构
┌─────────────┐

│   Nginx     │

│ (负载均衡)   │

└──────┬──────┘

│

┌───────────────┼───────────────┐

│               │               │

┌─────▼─────┐  ┌─────▼─────┐  ┌─────▼─────┐

│ Nacos 节点1│  │ Nacos 节点2│  │ Nacos 节点3│

│ 192.168.1.1│  │ 192.168.1.2│  │ 192.168.1.3│

└─────┬─────┘  └─────┬─────┘  └─────┬─────┘

│               │               │

└───────────────┼───────────────┘

│

┌─────▼─────┐

│   MySQL   │

│ (主从/集群)│

└───────────┘

---

## 二、部署步骤

### 1. 准备环境
- 3 台 Linux 服务器（或 Docker 容器）。
- MySQL 5.7+（建议主从或集群）。
- JDK 1.8+。

### 2. 配置 MySQL
在所有 Nacos 节点上修改 `conf/application.properties`，指向同一个 MySQL 实例。

### 3. 配置集群
编辑 `conf/cluster.conf`，每行一个节点 IP:Port：
192.168.1.1:8848

192.168.1.2:8848

192.168.1.3:8848

### 4. 启动集群
在每个节点上执行：
bash

sh startup.sh -m cluster

### 5. 配置 Nginx
nginx

upstream nacos_cluster {

server 192.168.1.1:8848;

server 192.168.1.2:8848;

server 192.168.1.3:8848;

}

server {

listen 8848;

location / {

proxy_pass http://nacos_cluster;

}

}

---

## 三、集群验证
bash

查看集群节点
curl -X GET "http://localhost:8848/nacos/v1/ns/operator/servers"

注册服务
curl -X POST "http://localhost:8848/nacos/v1/ns/instance?serviceName=test&ip=1.1.1.1&port=8080"

发现服务
curl -X GET "http://localhost:8848/nacos/v1/ns/instance/list?serviceName=test"

---

## 四、集群运维

### 节点扩缩容
- 扩容：新节点启动后自动加入集群。
- 缩容：停止节点前，先确认其他节点健康，然后关闭节点。

### 数据备份
- 定期备份 MySQL 数据库。
- 备份 `nacos/data/` 目录（内含配置快照）。

### 监控
- 通过 Nacos 控制台的「集群管理」查看节点状态。
- 使用 Prometheus + Grafana 监控 Nacos（Nacos 暴露 metrics 端点）。

---

## 小结

- Nacos 集群至少 3 节点，共享 MySQL。
- Nginx 做负载均衡，客户端配置多地址兜底。
- 集群部署是生产环境的必备技能。