# Nacos 性能优化

## 一、服务端优化

### 1. 调整 JVM 参数
bash

修改 startup.sh 中的 JAVA_OPT
JAVA_OPT="${JAVA_OPT} -server -Xms2g -Xmx2g -Xmn1g -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m"

- 堆内存建议 2GB~4GB（根据服务数和配置量调整）。
- 新生代大小建议为堆的 1/3~1/2。

### 2. 调整 Nacos 配置
properties

长轮询超时时间（默认 30s）
nacos.config.long-polling.timeout=30000

客户端心跳间隔（默认 5s）
nacos.naming.heartbeat.interval=5000

最大连接数
server.tomcat.max-threads=500

server.tomcat.accept-count=100

### 3. 使用 gRPC（Nacos 2.0+ 默认）

gRPC 比 HTTP 性能更好，支持双向流，减少连接数。确保客户端版本 >= 2.0。

---

## 二、客户端优化

### 1. 减少心跳频率

如果对服务发现实时性要求不高，可以调小心跳间隔：
yaml

spring:

cloud:

nacos:

discovery:

heart-beat-interval: 10000    # 默认 5s，改为 10s

heart-beat-retry: 3

### 2. 使用本地缓存

Nacos 客户端默认缓存服务列表和配置，减少对服务端的请求。缓存时间可通过 `naming-client-cache-beans` 调整。

### 3. 批量注册

如果服务实例很多，可以批量注册，减少网络开销。

---

## 三、数据库优化

### 1. MySQL 配置
ini

innodb_buffer_pool_size = 2G

innodb_log_file_size = 512M

max_connections = 500

### 2. 配置清理

Nacos 会保留配置的历史版本，定期清理不需要的历史版本：
sql

DELETE FROM his_config_info WHERE gmt_modified < DATE_SUB(NOW(), INTERVAL 30 DAY);

---

## 四、监控与告警

推荐使用 Prometheus + Grafana 监控 Nacos：

- 指标：请求量、延迟、连接数、内存、CPU。
- 告警：节点宕机、配置变更频繁、服务注册失败率高等。

---

## 小结

- 服务端：调大 JVM 堆、调整长轮询超时、使用 gRPC。
- 客户端：降低心跳频率、利用本地缓存。
- 数据库：优化 MySQL 配置，定期清理历史配置。
- 监控：Prometheus + Grafana 保障稳定运行。
