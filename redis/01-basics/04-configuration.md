# Redis 配置文件详解

Redis 的配置文件 `redis.conf` 是控制 Redis 行为的关键文件。以下是最常用和最重要的配置项分类说明。

---

## 一、基本配置
ini

是否以后台守护进程方式运行
daemonize yes

进程文件路径（当 daemonize yes 时生效）
pidfile /var/run/redis_6379.pid

监听端口
port 6379

绑定的 IP 地址（多个用空格分隔）
bind 127.0.0.1 -::1

客户端空闲超时时间（秒），0 表示永不超时
timeout 0

TCP 连接 backlog（排队连接数）
tcp-backlog 511

日志级别（debug / verbose / notice / warning）
loglevel notice

日志文件路径
logfile /var/log/redis/redis.log

数据库数量（默认 16 个，编号 0~15）
databases 16

---

## 二、安全配置
ini

设置密码（客户端连接时需要 AUTH 命令）
requirepass your_strong_password

重命名危险命令（防止误操作）
rename-command FLUSHALL ""

rename-command FLUSHDB ""

rename-command CONFIG ""

限制访问的命令（白名单方式，可禁用）
rename-command KEYS ""
保护模式（yes 时只接受回环地址连接，除非 bind 或设置密码）
protected-mode yes

---

## 三、持久化配置

### RDB（快照）
ini

保存策略：在 900 秒内有 1 次写操作则触发快照
save 900 1

save 300 10

save 60 10000

RDB 文件名
dbfilename dump.rdb

RDB 文件存放目录
dir /var/lib/redis

是否压缩 RDB 文件
rdbcompression yes

是否校验 RDB 文件（CRC64 校验）
rdbchecksum yes

停止写入如果最后一次 RDB 持久化失败
stop-writes-on-bgsave-error yes

### AOF（追加日志）
ini

开启 AOF 持久化
appendonly yes

AOF 文件名
appendfilename "appendonly.aof"

AOF 同步频率（always / everysec / no）
appendfsync everysec

是否在 AOF 重写时不进行 fsync
no-appendfsync-on-rewrite no

自动重写触发条件（当前 AOF 文件大小超过上次重写时的百分比）
auto-aof-rewrite-percentage 100

自动重写的最小 AOF 文件大小
auto-aof-rewrite-min-size 64mb

加载 AOF 时忽略尾部不完整的数据（防止崩溃导致无法启动）
aof-load-truncated yes

混合持久化（RDB + AOF，Redis 4.0+）
aof-use-rdb-preamble yes

---

## 四、内存管理与淘汰策略
ini

最大可用内存（字节），一般设置为物理内存的 70%~80%
maxmemory 256mb

内存淘汰策略（达到 maxmemory 时的行为）
volatile-lru: 从设置了过期时间的键中淘汰最近最少使用的
allkeys-lru: 从所有键中淘汰最近最少使用的（最常用）
volatile-lfu: 从设置了过期时间的键中淘汰最不经常使用的（4.0+）
allkeys-lfu: 从所有键中淘汰最不经常使用的（4.0+）
volatile-random: 从设置了过期时间的键中随机淘汰
allkeys-random: 从所有键中随机淘汰
volatile-ttl: 从设置了过期时间的键中淘汰即将过期的
noeviction: 不淘汰，写操作返回错误（默认）
maxmemory-policy allkeys-lru

LRU/LFU 算法的采样数量（越大越精确，但消耗 CPU）
maxmemory-samples 5

---

## 五、网络与连接配置
ini

最大客户端连接数
maxclients 10000

客户端输出缓冲区限制（普通/从节点/发布订阅）
client-output-buffer-limit normal 0 0 0

client-output-buffer-limit replica 256mb 64mb 60

client-output-buffer-limit pubsub 32mb 8mb 60

---

## 六、主从复制配置
ini

设置本节点为从节点，并指定主节点
replicaof 192.168.1.100 6379

如果主节点设置了密码，从节点需配置
masterauth your_password

从节点是否只读（默认 yes）
replica-read-only yes

复制缓冲区大小
repl-backlog-size 1mb

主节点多久向从节点发送心跳（秒）
repl-ping-replica-period 10

超时时间（秒）
repl-timeout 60

是否禁用 TCP_NODELAY（yes 减少带宽但增加延迟）
repl-disable-tcp-nodelay no

从节点优先级（哨兵选举时使用，越低优先级越高）
slave-priority 100

---

## 七、哨兵配置（sentinel.conf）

哨兵有独立的配置文件 `sentinel.conf`，常用配置如下：
ini

哨兵端口
port 26379

监控的主节点（mymaster 为自定义名称，2 表示至少 2 个哨兵同意才判定故障）
sentinel monitor mymaster 127.0.0.1 6379 2

主节点密码
sentinel auth-pass mymaster your_password

主观下线时间（毫秒）
sentinel down-after-milliseconds mymaster 5000

故障转移超时时间
sentinel failover-timeout mymaster 60000

并行同步的从节点数量
sentinel parallel-syncs mymaster 1

---

## 八、集群配置（cluster mode）
ini

开启集群模式
cluster-enabled yes

集群配置文件（自动生成，不可手动编辑）
cluster-config-file nodes-6379.conf

节点超时时间（毫秒）
cluster-node-timeout 15000

副本迁移（允许从节点自动迁移到其他主节点）
cluster-migration-barrier 1

集群节点之间是否开启认证
cluster-require-full-coverage yes
---

## 九、慢查询与日志
ini

慢查询阈值（微秒，10000 = 10ms）
slowlog-log-slower-than 10000

慢查询日志最大条数
slowlog-max-len 128

日志级别
loglevel notice

是否记录系统日志（syslog）
syslog-enabled no

---

## 十、性能调优建议

1. **关闭 THP（透明大页）**：在宿主机执行 `echo never > /sys/kernel/mm/transparent_hugepage/enabled`，可降低延迟。
2. **调整内核参数**：`net.core.somaxconn = 1024`、`vm.overcommit_memory = 1`。
3. **合理设置 maxmemory**：避免使用 swap。
4. **选择合适的淘汰策略**：大部分场景用 `allkeys-lru`。
5. **持久化权衡**：
    - 只做缓存：关闭持久化（`save ""`、`appendonly no`）。
    - 需要数据恢复：RDB + AOF 混合模式。
6. **连接池**：客户端使用连接池，避免频繁创建连接。

---

## 十一、配置生效方式

1. **启动时指定配置文件**：`redis-server /path/to/redis.conf`
2. **运行时动态修改**（无需重启）：
   bash

redis-cli CONFIG SET maxmemory 512mb

redis-cli CONFIG SET requirepass newpassword

3. **持久化运行时修改**：`redis-cli CONFIG REWRITE` 将当前配置写入配置文件。

---

## 小结

- 配置文件是 Redis 运维的核心，重点掌握持久化、内存淘汰、安全、复制相关配置。
- 生产环境中务必设置 `requirepass`、`rename-command` 高危命令、合理 `maxmemory`。
- 使用 `CONFIG SET` 可以在线调整参数，无需重启服务。