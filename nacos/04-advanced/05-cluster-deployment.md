# Nacos 集群部署

## 一、为什么需要集群？

- 高可用：单点故障不影响整体服务。
- 高性能：分摊请求压力。
- 数据安全：配置数据持久化到 MySQL，不丢失。

---

## 二、集群架构

┌──────────────┐

│  VIP / SLB   │

└──────┬───────┘

┌───────────┼───────────┐

│           │           │

┌───▼───┐  ┌───▼───┐  ┌───▼───┐

│Nacos-1│  │Nacos-2│  │Nacos-3│

│8848   │  │8848   │  │8848   │

└───┬───┘  └───┬───┘  └───┬───┘

└──────────┼──────────┘

│

┌──────▼──────┐

│   MySQL     │

│ (主从/集群)  │

└─────────────┘

- 推荐至少 3 个 Nacos 节点（奇数，Raft 选举需要）。
- 前端加 VIP 或 Nginx 做负载均衡。
- 后端使用 MySQL 集群存储配置数据。

---

## 三、部署步骤

### 1. 准备 MySQL

创建数据库并执行初始化脚本（`conf/mysql-schema.sql`）。

### 2. 配置每个节点

修改 `conf/application.properties`：

properties

使用 MySQL

spring.datasource.platform=mysql

db.url.0=jdbc:mysql://192.168.1.1:3306/nacos_config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true

db.user=root

db.password=123456

集群配置

nacos.member.list=192.168.1.1:8848,192.168.1.2:8848,192.168.1.3:8848

### 3. 启动集群

bash

每个节点执行

sh startup.sh

### 4. 配置负载均衡

Nginx 配置示例：

nginx

upstream nacos_cluster {

server 192.168.1.1:8848;

server 192.168.1.2:8848;

server 192.168.1.3:8848;

}

server {

listen 8848;

location / {

proxy_pass http://nacos_cluster
;

}

}

---

## 四、验证

bash

curl -X GET "http://localhost:8848/nacos/v1/ns/service/list?pageNo=1&pageSize=10
"

查看集群节点状态：访问 Nacos 控制台 → 集群管理。

---

## 五、注意事项

- 所有节点必须使用同一个 MySQL 数据库。
- 节点时间必须同步（NTP）。
- 防火墙开放端口：8848（客户端）、9848（gRPC）、7848（Raft）。
- 集群模式下不要使用内置 Derby 数据库。

---

## 小结

- 集群部署至少 3 节点 + MySQL。
- 前端加 VIP/Nginx 负载均衡。
- 注意端口开放和时间同步。

