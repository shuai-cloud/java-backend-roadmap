# Redis 内存优化策略

Redis 是内存数据库，内存是其最宝贵的资源。合理的内存优化可以降低成本、提升性能。

---

## 一、内存从哪里来？

Redis 的内存消耗主要包括：
- **数据内存**：存储 key-value 占用的内存（最主要）。
- **元数据**：字典结构、过期信息、主从复制缓冲区等。
- **碎片**：内存分配器（jemalloc）产生的内部碎片和外部碎片。
- **其他**：AOF 缓冲区、客户端输出缓冲区、Lua 脚本缓存等。

---

## 二、选择合适的数据结构

### 1. 使用更紧凑的内部编码

Redis 对不同数据类型有多种内部编码，内存效率不同：

| 数据类型 | 内部编码 | 内存效率 | 适用场景 |
|----------|----------|----------|----------|
| String | int / embstr / raw | int 最省，embstr 省，raw 费 | 短字符串用 embstr |
| Hash | ziplist / hashtable | ziplist 省（字段少、值短时） | 小对象用 ziplist |
| List | quicklist | 适中 | 默认 |
| Set | intset / hashtable | intset 省（全整数且少时） | 小整数集合用 intset |
| ZSet | ziplist / skiplist | ziplist 省（元素少时） | 小有序集合用 ziplist |

**控制转换阈值**（在 redis.conf 中配置）：

ini

hash-max-ziplist-entries 512    # 字段数超过此值转为 hashtable

hash-max-ziplist-value 64       # 字段值超过此字节转为 hashtable

list-max-ziplist-size -2        # -2 表示 8KB 以内用 ziplist

set-max-intset-entries 512      # 整数集合元素数上限

zset-max-ziplist-entries 128    # 有序集合元素数上限

zset-max-ziplist-value 64       # 有序集合元素值字节上限

### 2. 使用 Hash 代替 String 存储对象

❌ 不推荐：

SET user:1001:name "Alice"

SET user:1001:age 30

SET user:1001:email "alice@example.com"

✅ 推荐：

HSET user:1001 name "Alice" age 30 email "alice@example.com"

一个 Hash 对象的元数据开销远小于多个 String key 的开销。

### 3. 使用 HyperLogLog 代替 Set 做基数统计

如果只需要统计 UV（不重复访客数），用 PFADD 代替 SADD，每个 HyperLogLog 固定占用 12KB，无论数据量多大。

---

## 三、合理设置过期时间

- 所有缓存数据都应该设置 TTL，避免无用数据长期占用内存。
- 使用 `EXPIRE`、`SETEX` 或 `@Cacheable` 的 `ttl` 属性。
- 定期扫描过期 key 会消耗 CPU，但内存收益更大。

---

## 四、控制 key 的长度

- key 名尽量简短：`user:1001` 比 `user_info_for_user_id_1001` 节省大量内存。
- 但也要有可读性，平衡两者。

---

## 五、使用内存淘汰策略

当内存达到 `maxmemory` 限制时，Redis 会根据 `maxmemory-policy` 淘汰数据：

ini

maxmemory 4gb

maxmemory-policy allkeys-lru    # 推荐

常用策略：
- `allkeys-lru`：淘汰最近最少使用的 key（最常用）。
- `volatile-lru`：只淘汰设置了过期时间的 key 中的 LRU。
- `allkeys-lfu`：淘汰最不经常使用的 key（4.0+）。
- `noeviction`：不淘汰，写操作返回错误（默认）。

---

## 六、使用共享对象池

Redis 内部会共享 0~9999 的整数对象（`REDIS_SHARED_INTEGERS`），所以 `SET key 100` 和 `SET other 100` 共用同一个对象，不额外消耗内存。但字符串对象不会共享。

---

## 七、内存碎片整理

### 查看碎片率

bash

redis-cli INFO memory | grep mem_fragmentation_ratio

- `mem_fragmentation_ratio > 1.5`：碎片较多，需要整理。
- `mem_fragmentation_ratio < 1`：可能发生了 swap，危险！

### 整理碎片（Redis 4.0+）

ini

activedefrag yes

active-defrag-threshold-lower 10     # 碎片率超过 10% 开始整理

active-defrag-threshold-upper 100    # 碎片率超过 100% 全力整理

active-defrag-cycle-min 25           # 整理占 CPU 时间的最小比例

active-defrag-cycle-max 75           # 最大比例

也可以在运行时动态开启：

bash

redis-cli CONFIG SET activedefrag yes

---

## 八、减少复制和持久化的内存开销

- 主从复制时，主节点需要维护复制积压缓冲区（`repl-backlog-size`），适当减小（如 1MB~10MB）。
- AOF 重写期间，子进程会共享父进程内存（写时复制），此时内存会短暂增长。尽量在低峰期触发重写。

---

## 九、监控内存使用

bash

查看内存统计

redis-cli INFO memory

查看每个 key 的内存占用（Redis 4.0+）

redis-cli MEMORY USAGE mykey

查看内存最多的 key（需要扫描）

redis-cli --bigkeys

---

## 十、实战优化案例

**问题**：一个电商系统的商品缓存，每个商品用一个 String 存储 JSON（约 2KB），100 万个商品占用 2GB 内存。

**优化方案**：
1. 改用 Hash 存储商品字段（价格、库存、标题等），避免反序列化整个 JSON。
2. 只缓存热点商品（前 20%），冷数据走数据库。
3. 设置 TTL 为 1 小时，避免冷数据常驻内存。

**效果**：内存占用降至 800MB，命中率保持在 85% 以上。

---

## 小结

- 内存优化从数据结构选择、过期策略、淘汰策略、碎片整理等多方面入手。
- 使用 `MEMORY USAGE` 命令诊断大 key。
- 定期监控 `mem_fragmentation_ratio` 和 `maxmemory` 使用率。