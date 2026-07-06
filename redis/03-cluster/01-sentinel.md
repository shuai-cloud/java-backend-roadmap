# Redis Sentinel：哨兵高可用方案

Redis Sentinel 是 Redis 官方提供的高可用解决方案，用于监控 Redis 主从架构，自动执行故障转移，并向客户端提供服务发现。

---

## 一、为什么需要 Sentinel？

在主从复制模式下，如果主节点宕机，需要人工将一个从节点提升为主节点，并修改客户端配置。这个过程不可靠且耗时。Sentinel 可以自动完成：

- **监控**：持续检查主节点和从节点是否正常运行。
- **通知**：当被监控的节点出现问题时，通知管理员或其他程序。
- **自动故障转移**：当主节点不可用时，自动从从节点中选举一个新的主节点，并将其他从节点指向新主节点。
- **配置提供**：客户端连接 Sentinel 获取当前主节点的地址。

---

## 二、Sentinel 架构

+-------------------+       +-------------------+

|   Sentinel 1      |       |   Sentinel 2      |

|   (port 26379)    |       |   (port 26379)    |

+--------+----------+       +--------+----------+

|                           |

+---------------------------+

|

+-----------v------------+

|   Redis Master         |

|   (port 6379)          |

+--------+---------------+

|

+--------+--------+

|                  |

+-----v------+    +-----v------+

| Slave 1    |    | Slave 2    |

| (port 6380)|    | (port 6381)|

+------------+    +------------+

- Sentinel 本身也是一个 Redis 服务器，但功能特殊。
- 通常部署 **奇数个**（至少 3 个）Sentinel 实例，以避免脑裂。
- Sentinel 之间通过 Gossip 协议交换信息。

---

## 三、Sentinel 配置文件（sentinel.conf）

ini

哨兵端口

port 26379

守护进程

daemonize yes

日志文件

logfile /var/log/redis/sentinel.log

监控的主节点：mymaster 是自定义名称，2 表示至少 2 个哨兵同意才能判定故障

sentinel monitor mymaster 127.0.0.1 6379 2

主节点密码（如果有）

sentinel auth-pass mymaster your_password

主观下线时间（毫秒）：哨兵认为节点宕机的超时时间

sentinel down-after-milliseconds mymaster 5000

故障转移超时时间（毫秒）

sentinel failover-timeout mymaster 180000

故障转移后，同时同步数据的从节点数量（1 表示逐个同步，避免主节点负载过高）

sentinel parallel-syncs mymaster 1

通知脚本（可选）

sentinel notification-script mymaster /var/redis/notify.sh

客户端重新配置脚本（可选）

sentinel client-reconfig-script mymaster /var/redis/reconfig.sh

---

## 四、启动 Sentinel

bash

redis-sentinel /path/to/sentinel.conf

或

redis-server /path/to/sentinel.conf --sentinel

---

## 五、Sentinel 的工作流程

### 1. 主观下线（Subjectively Down，SDOWN）
单个 Sentinel 在 `down-after-milliseconds` 时间内没有收到节点的有效回复（PING、INFO 等），则认为该节点主观下线。

### 2. 客观下线（Objectively Down，ODOWN）
当 Sentinel 认为主节点主观下线后，会向其他 Sentinel 发送 `SENTINEL is-master-down-by-addr` 命令，询问它们对该主节点的看法。如果获得足够数量的确认（>= quorum），则将该主节点标记为客观下线。

### 3. 领导者选举
Sentinel 之间使用 Raft 算法选举一个领导者（Leader），由领导者负责执行故障转移。

### 4. 故障转移
领导者执行以下步骤：
1. 从健康的从节点中选出一个作为新主节点（优先级高、数据新、复制偏移量大）。
2. 向该从节点发送 `SLAVEOF NO ONE` 使其成为主节点。
3. 向其他从节点发送 `SLAVEOF new_master_ip new_master_port`，让它们复制新主节点。
4. 将旧主节点标记为从节点，待其恢复后自动成为新主节点的从节点。
5. 更新自身记录的主节点地址。

### 5. 通知客户端
客户端通过 `SENTINEL get-master-addr-by-name mymaster` 获取当前主节点地址。许多客户端库（如 Jedis、Lettuce）内置了 Sentinel 支持，自动监听主节点变化。

---

## 六、Sentinel 常用命令

bash

查看所有被监控的主节点

SENTINEL masters

查看指定主节点的详细信息

SENTINEL master mymaster

查看从节点列表

SENTINEL slaves mymaster

查看 Sentinel 列表

SENTINEL sentinels mymaster

获取当前主节点地址

SENTINEL get-master-addr-by-name mymaster

手动故障转移（即使主节点正常）

SENTINEL failover mymaster

重置主节点状态（清除故障记录）

SENTINEL reset mymaster

---

## 七、Java 客户端集成（Lettuce）

java

RedisURI redisUri = RedisURI.Builder

.sentinel("sentinel-host1", 26379, "mymaster")

.withSentinel("sentinel-host2", 26379)

.withSentinel("sentinel-host3", 26379)

.withPassword("password".toCharArray())

.build();

RedisClient client = RedisClient.create(redisUri);

StatefulRedisConnection<String, String> connection = client.connect();

RedisCommands<String, String> commands = connection.sync();

commands.set("foo", "bar");

Lettuce 会自动监听 Sentinel 的通知，当主节点切换时自动更新连接。

---

## 八、Sentinel 的局限性

- **不支持自动分片**：Sentinel 只解决高可用，不解决数据容量扩展问题。
- **故障转移期间有短暂不可用**：通常几秒到十几秒。
- **配置相对复杂**：需要维护多个 Sentinel 实例。
- **客户端需要支持 Sentinel**：老旧的客户端可能不支持。

---

## 九、生产部署建议

- 部署 **3 个或 5 个** Sentinel 实例，分布在不同的机器上。
- Sentinel 的 `quorum` 设置为 `N/2 + 1`（如 3 个 Sentinel 设 2）。
- 主节点和从节点部署在不同机架/可用区。
- 设置合理的 `down-after-milliseconds`（通常 5~10 秒）。
- 监控 Sentinel 自身健康状态。

---

## 小结

- Sentinel 提供了自动故障转移能力，是中小规模 Redis 高可用的首选方案。
- 与主从复制配合使用，实现读写分离和高可用。
- 客户端需要集成 Sentinel 感知能力。
- 如果数据量超过单机内存，则需要考虑 Redis Cluster。