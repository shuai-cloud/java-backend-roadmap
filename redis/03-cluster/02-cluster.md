# Redis Cluster：分布式集群

Redis Cluster 是 Redis 官方提供的分布式解决方案，支持**自动分片**和**高可用**，数据自动分布在多个节点上，且部分节点故障时集群仍可正常工作。

---

## 一、为什么需要 Cluster？

- **数据容量**：单机 Redis 内存有限（通常 ≤ 64GB），Cluster 可将数据分散到多台机器。
- **吞吐量**：多节点分担读写压力，线性扩展性能。
- **高可用**：自动故障转移，无需额外 Sentinel 组件。

---

## 二、Cluster 核心概念

### 1. 哈希槽（Hash Slot）
- Redis Cluster 共有 **16384 个哈希槽**。
- 每个 key 通过 CRC16 算法计算哈希值，然后对 16384 取模，决定该 key 属于哪个槽。
- 每个节点负责一部分哈希槽（例如 3 节点集群：节点 A 负责 0~5460，节点 B 负责 5461~10922，节点 C 负责 10923~16383）。

### 2. 节点间通信
- 节点之间通过 **Gossip 协议** 交换元数据（节点状态、槽分配等）。
- 每个节点都维护集群的完整拓扑视图。
- 默认使用 10000 + 端口号（如 6379 → 16379）作为集群总线端口。

### 3. 分片与复制
- 每个主节点可以有多个从节点（推荐至少 1 个）。
- 从节点负责复制主节点数据，并在主节点故障时接管。

### 4. 智能客户端
- 客户端可以缓存槽与节点的映射关系，直接向正确的节点发送请求。
- 如果请求被重定向（MOVED），客户端需要更新缓存。

---

## 三、Cluster 配置示例

ini

开启集群模式

cluster-enabled yes

集群配置文件（自动生成，不可手动修改）

cluster-config-file nodes-6379.conf

节点超时时间（毫秒）

cluster-node-timeout 15000

从节点数量（允许迁移的副本数）

cluster-migration-barrier 1

是否要求集群完整才能提供服务（生产建议 no）

cluster-require-full-coverage no

---

## 四、搭建 Cluster（3 主 3 从）

### 1. 准备 6 个 Redis 实例（端口 7000~7005）

bash

mkdir -p /redis-cluster/{7000,7001,7002,7003,7004,7005}

每个目录下创建 `redis.conf`，内容示例（以 7000 为例）：

ini

port 7000

cluster-enabled yes

cluster-config-file nodes-7000.conf

cluster-node-timeout 5000

appendonly yes

daemonize yes

pidfile /var/run/redis_7000.pid

logfile /var/log/redis_7000.log

dir /redis-cluster/7000

### 2. 启动所有实例

bash

redis-server /redis-cluster/7000/redis.conf

redis-server /redis-cluster/7001/redis.conf

... 启动所有 6 个
### 3. 创建集群

使用 `redis-cli` 创建集群（Redis 5.0+）：

bash

redis-cli --cluster create \

127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 \

127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 \

--cluster-replicas 1

- `--cluster-replicas 1` 表示为每个主节点分配 1 个从节点。
- 命令会自动分配哈希槽，并将前三个设为主，后三个设为从。

### 4. 验证集群

bash

redis-cli -c -p 7000 cluster info

redis-cli -c -p 7000 cluster nodes

---

## 五、Cluster 常用命令

bash

查看集群信息

CLUSTER INFO

查看节点列表

CLUSTER NODES

查看槽分配情况

CLUSTER SLOTS

计算 key 属于哪个槽

CLUSTER KEYSLOT mykey

统计 key 数量

CLUSTER COUNTKEYSINSLOT slot

手动故障转移（从节点发起）

CLUSTER FAILOVER [FORCE|TAKEOVER]

重新分片（在线迁移槽）

redis-cli --cluster reshard 127.0.0.1:7000

添加节点

redis-cli --cluster add-node new_host:new_port existing_host:existing_port [--cluster-slave|--cluster-master-id id]

删除节点

redis-cli --cluster del-node host:port node_id

---

## 六、客户端访问 Cluster

### 命令行

bash

必须使用 -c 参数启用集群模式

redis-cli -c -p 7000

127.0.0.1:7000> SET foo bar

-> Redirected to slot [12182] located at 127.0.0.1:7002

OK

### Java 示例（Jedis Cluster）

java

Set<HostAndPort> nodes = new HashSet<>();

nodes.add(new HostAndPort("127.0.0.1", 7000));

nodes.add(new HostAndPort("127.0.0.1", 7001));

nodes.add(new HostAndPort("127.0.0.1", 7002));

JedisCluster jedisCluster = new JedisCluster(nodes);

jedisCluster.set("foo", "bar");

String value = jedisCluster.get("foo");

jedisCluster.close();

### Java 示例（Lettuce Cluster）

java

RedisClusterClient client = RedisClusterClient.create(

RedisURI.create("redis://127.0.0.1:7000"));

StatefulRedisClusterConnection<String, String> conn = client.connect();

RedisAdvancedClusterCommands<String, String> commands = conn.sync();

commands.set("key", "value");

---

## 七、Cluster 的故障转移

- 当主节点宕机时，其从节点会检测到（通过 Gossip 协议），并发起选举。
- 选举成功后，从节点升级为主节点，接管原主节点的哈希槽。
- 整个过程自动完成，无需人工干预。
- 如果主节点没有从节点，集群会进入 **fail** 状态（取决于 `cluster-require-full-coverage` 配置）。

---

## 八、Cluster 的局限性

1. **不支持多 key 操作**：如果多个 key 不在同一个槽（节点），无法执行 `MSET`、`SINTER` 等跨槽操作。可以使用 **Hash Tag** 强制将相关 key 放到同一槽：`{user:1001}:name` 和 `{user:1001}:age` 的花括号内容相同，会分配到同一槽。
2. **事务限制**：`MULTI/EXEC` 只能在同一个节点上执行，不能跨节点。
3. **Lua 脚本限制**：脚本中涉及的 key 必须在同一个节点上。
4. **数据倾斜**：如果某些 key 访问特别频繁（Hot Key），会导致单节点负载过高。
5. **批量操作性能**：`MGET` 如果 key 分布在多个节点，客户端需要并发请求多个节点。

---

## 九、Cluster vs Sentinel

| 特性 | Sentinel | Cluster |
|------|----------|---------|
| 数据分片 | 不支持 | 自动分片（16384 槽） |
| 高可用 | 自动故障转移 | 自动故障转移 |
| 数据容量 | 受单机内存限制 | 可水平扩展 |
| 写性能 | 单点写入 | 多节点写入 |
| 复杂度 | 较低 | 较高 |
| 客户端要求 | 支持 Sentinel | 支持 Cluster |
| 跨 key 操作 | 支持 | 受限（需 Hash Tag） |

---

## 十、生产部署建议

- 至少 6 个节点（3 主 3 从），主从分布在不同物理机。
- 每个主节点内存控制在 4~8 GB，避免全量同步耗时过长。
- 使用 Hash Tag 将有业务关联的 key 放到同一槽。
- 监控集群状态：`redis-cli --cluster check host:port`。
- 避免频繁的在线重分片，尽量在业务低峰期进行。

---

## 小结

- Redis Cluster 提供了自动分片和高可用，适合大规模数据场景。
- 客户端需要支持 Cluster 协议（MOVED 重定向、ASK 重定向）。
- 注意跨 key 操作的限制，使用 Hash Tag 解决。
- 相比 Sentinel，Cluster 更复杂但扩展性更好。