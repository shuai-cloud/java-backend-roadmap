# Redis 进阶面试题

---

## 1. Redis 的底层数据结构有哪些？

| 数据类型 | 底层编码 | 说明 |
|----------|----------|------|
| String | int / embstr / raw | int 存储整数，embstr 存储短字符串，raw 存储长字符串 |
| Hash | ziplist / hashtable | ziplist 在字段少且值小时使用，否则转为 hashtable |
| List | quicklist | 由多个 ziplist 组成的链表 |
| Set | intset / hashtable | intset 在元素全为整数且数量少时使用 |
| ZSet | ziplist / skiplist | ziplist 在元素少时使用，否则使用 skiplist + dict |

---

## 2. 什么是跳表（skiplist）？为什么 ZSet 用它？

- **跳表**：一种多层链表结构，通过维护多级索引实现快速查找，平均时间复杂度 O(log N)。
- **为什么 ZSet 用跳表**：
    - 支持高效的插入、删除、范围查询（O(log N)）。
    - 实现简单，相比平衡树更容易理解和调试。
    - 支持灵活的分数更新。
- **为什么不用红黑树**：红黑树实现复杂，范围查询效率不如跳表（跳表只需遍历链表）。

---

## 3. Redis 的哈希表是如何扩容的？什么是渐进式 rehash？

- **扩容条件**：当哈希表的负载因子（used/size）大于 1 时触发扩容（如果正在进行 BGSAVE 或 BGREWRITEAOF，则大于 5 时触发）。
- **渐进式 rehash**：
    - 维持两个哈希表（ht[0] 和 ht[1]），ht[1] 大小为 ht[0] 的两倍。
    - 每次对哈希表进行操作（增删改查）时，顺带将 ht[0] 的一个桶迁移到 ht[1]。
    - 全部迁移完成后，释放 ht[0]，将 ht[1] 设为 ht[0]，并创建新的空 ht[1]。
- **优点**：避免一次性 rehash 导致的长时间阻塞。

---

## 4. Redis 的过期键是如何删除的？为什么需要定期删除？

- **惰性删除**：访问 key 时检查是否过期，过期则删除。
- **定期删除**：每隔 100ms 随机抽取 20 个设置了过期时间的 key，删除其中过期的。如果超过 25% 的 key 过期，则继续抽取下一批。
- **为什么需要定期删除**：惰性删除可能导致过期 key 长期占用内存（如从未被访问的 key）。定期删除主动清理，平衡 CPU 和内存。

---

## 5. Redis 的 `WATCH` 命令是如何实现乐观锁的？

- `WATCH` 监视一个或多个 key，在事务执行前检查这些 key 是否被其他客户端修改过。
- 如果在 `WATCH` 之后、`EXEC` 之前，被监视的 key 发生了变化，则事务执行失败（返回 nil）。
- 适用于需要 CAS（Compare And Swap）的场景，如库存扣减。

---

## 6. Redis 的复制积压缓冲区是什么？有什么作用？

- **复制积压缓冲区**：主节点维护的一个固定大小的环形缓冲区（默认 1MB），用于存储最近的写命令。
- **作用**：当从节点断开重连时，如果复制偏移量仍在缓冲区范围内，只需执行部分重同步（增量同步），避免全量复制。
- **配置**：`repl-backlog-size`，可根据网络状况和重连频率调整。

---

## 7. Redis Sentinel 的故障转移过程是怎样的？

1. Sentinel 检测到主节点主观下线（SDOWN）。
2. 向其他 Sentinel 发送确认，达到 quorum 后标记为客观下线（ODOWN）。
3. Sentinel 之间选举一个 Leader。
4. Leader 从健康的从节点中选出一个新主节点（优先级高、数据新、复制偏移量大）。
5. 向新主节点发送 `SLAVEOF NO ONE`。
6. 向其他从节点发送 `SLAVEOF new_master_ip new_master_port`。
7. 将旧主节点标记为从节点，待其恢复后自动复制新主节点。

---

## 8. Redis Cluster 的节点通信机制是什么？

- 节点间通过 **Gossip 协议** 交换元数据（节点状态、槽分配、主从关系等）。
- 每个节点定期向其他节点发送 PING 消息，包含自己的状态和已知的其他节点信息。
- 收到 PING 的节点回复 PONG。
- 使用集群总线端口（默认 10000 + 端口号）进行通信。

---

## 9. Redis Cluster 的 MOVED 和 ASK 重定向有什么区别？

- **MOVED**：客户端请求的 key 所在的槽已经永久迁移到另一个节点，客户端需要更新本地槽映射缓存，并直接访问新节点。
- **ASK**：槽正在迁移中，客户端需要先向目标节点发送 ASKING 命令，然后再发送请求。ASK 重定向不会更新客户端缓存，只是临时处理。

---

## 10. 什么是 Redis 的哈希标签（Hash Tag）？有什么作用？

- **哈希标签**：在 key 中使用花括号 `{}` 括起来的部分，如 `{user:1001}:name`。
- **作用**：强制将多个 key 分配到同一个哈希槽，从而支持跨 key 操作（如 MSET、SINTER、事务）。
- **注意**：只有花括号内的内容参与哈希计算，花括号外的不影响。

---

## 11. Redis 的 `UNLINK` 和 `DEL` 有什么区别？

- `DEL`：同步删除，会阻塞 Redis 主线程直到内存回收完成。删除大 key 时可能导致长时间阻塞。
- `UNLINK`：异步删除，将 key 从键空间中移除，然后后台线程逐步回收内存。不会阻塞主线程。

**推荐**：删除大 key 时使用 `UNLINK`。

---

## 12. Redis 的 `MEMORY USAGE` 命令如何计算内存？

- `MEMORY USAGE key` 返回 key 及其值所占用的内存字节数（近似值）。
- 包括 key 本身的长度、值的大小、数据结构开销（如 dict entry、ziplist 头等）。
- 不包括序列化后的长度（如 RDB 文件中的大小）。

---

## 13. Redis 的 `DEBUG OBJECT` 命令有什么用？

- 返回 key 的内部编码、引用计数、最近访问时间等信息。
- 用于调试和分析 key 的内部状态。
- **注意**：生产环境慎用，可能泄露敏感信息。

---

## 14. 什么是 Redis 的碎片整理？如何配置？

- **内存碎片**：由于内存分配器（jemalloc）的特性，分配和释放内存后会产生碎片。
- **碎片整理**：Redis 4.0+ 支持在线整理碎片，通过移动数据合并空闲内存。
- **配置**：
  ini

activedefrag yes

active-defrag-threshold-lower 10    # 碎片率超过 10% 开始整理

active-defrag-threshold-upper 100   # 碎片率超过 100% 全力整理

active-defrag-cycle-min 25          # 整理占 CPU 时间的最小比例

active-defrag-cycle-max 75          # 最大比例

---

## 15. 什么是 Redis 的 IO 多线程？如何配置？

- Redis 6.0+ 引入多线程处理网络 IO 读写，但命令执行仍然是单线程。
- 多线程可以充分利用多核 CPU，提升网络吞吐量。
- **配置**：

ini

io-threads 4          # IO 线程数（建议不超过 CPU 核心数）

io-threads-do-reads yes  # 是否启用多线程读取

---

## 16. Redis 的 `CLIENT PAUSE` 命令有什么用？

- 暂停处理客户端请求，用于在故障转移期间阻止写入，保证数据一致性。
- 可以指定暂停时间（毫秒）或等待所有从节点同步完成。

---

## 17. Redis 的 `WAIT` 命令如何实现同步复制？

- `WAIT numreplicas timeout`：阻塞当前客户端，直到至少有 numreplicas 个从节点确认收到了所有写命令，或超时。
- 返回确认的从节点数量。
- 用于实现强一致性（至少同步到 N 个从节点后才返回）。

---

## 18. 什么是 Redis 的 RedLock 算法？

- RedLock 是 Redis 官方提出的分布式锁算法，用于解决单点 Redis 锁在主从切换时可能失效的问题。
- **原理**：同时在多个独立的 Redis 实例上获取锁，只有当超过半数实例加锁成功时才认为锁获取成功。
- **缺点**：实现复杂，依赖时钟同步，性能较差。生产环境较少使用，推荐 Redisson 的锁实现。

---

## 19. Redis 的 `SCAN` 命令如何保证不遗漏数据？

- `SCAN` 采用游标（cursor）方式迭代，每次返回一批 key 和新游标。
- 当游标为 0 时表示遍历完成。
- **不保证**：在遍历过程中新增或删除的 key 可能被遗漏或重复出现（弱一致性）。
- **适用场景**：代替 `KEYS` 进行非阻塞的 key 扫描。

---

## 20. Redis 的 `SORT` 命令有什么性能问题？如何优化？

- `SORT` 命令可以对 List、Set、ZSet 进行排序，支持 BY、GET、STORE 等选项。
- **性能问题**：`SORT` 需要加载所有元素到内存进行排序，如果数据量大，会消耗大量内存和 CPU。
- **优化**：
- 使用 ZSet 替代需要排序的场景。
- 限制排序数量（LIMIT）。
- 避免在大型集合上使用 SORT。
- 考虑在应用层排序。

---

## 21. Redis 的 `BITMAP` 有什么应用场景？

- **Bitmap**：通过位操作（SETBIT、GETBIT、BITCOUNT、BITOP）实现高效存储和统计。
- **应用场景**：
- 用户签到（365 天用 365 bit ≈ 46 字节）。
- 活跃用户统计（每天一个 bitmap，BITOP 求交/并）。
- 布隆过滤器的底层实现。

---

## 22. Redis 的 `HyperLogLog` 的误差范围是多少？适用场景？

- **误差范围**：标准误差约 0.81%。
- **适用场景**：UV 统计（不重复访客数）、独立 IP 统计等不需要精确计数的场景。
- **特点**：固定占用 12KB 内存，无论数据量多大。

---

## 23. Redis 的 `GEO` 底层数据结构是什么？精度如何？

- **底层**：基于 ZSet，将经纬度编码为 Geohash 作为 score。
- **精度**：默认 52 位编码，误差约 0.3 米。
- **注意**：`GEORADIUS` 在 Redis 6.2+ 中已被标记为废弃，推荐使用 `GEOSEARCH`。

---

## 24. Redis 的 `ACL` 功能是什么？如何配置？

- **ACL（Access Control List）**：Redis 6.0+ 引入的权限控制机制，支持用户管理和命令权限限制。
- **配置**：

bash

ACL SETUSER alice on >password ~* +@all -@dangerous

ACL SETUSER bob on >password ~cached:* +get +set

- **命令**：`ACL LIST`、`ACL USERS`、`ACL WHOAMI`。

---

## 25. Redis 的 `RESP3` 协议有什么改进？

- RESP3 是 Redis 6.0+ 引入的新协议，相比 RESP2 的主要改进：
- 支持更多的数据类型（如 Map、Set、Push、Null 等）。
- 支持服务端推送（如 Pub/Sub 的自动通知）。
- 更好的类型安全性和可扩展性。

---

## 26. 如何排查 Redis 的慢查询？

- 配置 `slowlog-log-slower-than`（如 10000 微秒）和 `slowlog-max-len`。
- 使用 `SLOWLOG GET 10` 查看最近慢查询。
- 分析慢查询的命令、耗时、客户端地址。
- 优化方向：使用 SCAN 代替 KEYS、拆分大 key、避免全量操作。

---

## 27. 如何监控 Redis 的性能？

- 使用 `INFO` 命令查看各项指标。
- 使用 `redis-cli --stat` 实时监控。
- 使用 `redis-cli --latency` 测量延迟。
- 使用 `redis-cli --bigkeys` 和 `--hotkeys` 分析大 key 和热 key。
- 使用第三方工具：RedisInsight、Prometheus + redis_exporter + Grafana。

---

## 28. Redis 的 `CONFIG REWRITE` 命令有什么作用？

- 将当前运行时配置（通过 `CONFIG SET` 修改的）持久化到配置文件中。
- 避免重启后配置丢失。

---

## 29. Redis 的 `DEBUG SLEEP` 命令有什么风险？

- `DEBUG SLEEP seconds` 会让 Redis 主线程休眠指定秒数，期间无法处理任何请求。
- **风险**：生产环境绝对禁止使用，会导致服务完全不可用。

---

## 30. 什么是 Redis 的 `LFU` 淘汰策略？和 `LRU` 有什么区别？

- **LRU（Least Recently Used）**：淘汰最近最少使用的 key，基于访问时间。
- **LFU（Least Frequently Used）**：淘汰最不经常使用的 key，基于访问频率（Redis 4.0+）。
- **区别**：LRU 只考虑最近一次访问时间，LFU 考虑历史访问频率。对于周期性热点数据，LFU 更准确。
- **配置**：`maxmemory-policy allkeys-lfu`。