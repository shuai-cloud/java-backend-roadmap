# BigKey 与 HotKey 的处理

BigKey 和 HotKey 是 Redis 生产环境中最常见的两类性能问题。

---

## 一、什么是 BigKey？

**BigKey** 是指占用内存过大或包含元素过多的 key。通常：

- String：值 > 10KB
- Hash：字段数 > 5000
- List：元素数 > 10000
- Set：元素数 > 10000
- ZSet：元素数 > 10000

### BigKey 的危害
- **阻塞操作**：`SMEMBERS`、`LRANGE`、`HGETALL` 等命令遍历所有元素，耗时较长。
- **网络拥塞**：获取一个大 key 会产生大量的网络传输。
- **内存不均**：导致集群中某些节点内存使用率过高（数据倾斜）。
- **删除困难**：`DEL` 大 key 会阻塞 Redis 主线程（Redis 4.0 后用 `UNLINK` 异步删除）。

---

## 二、如何发现 BigKey？

### 1. redis-cli --bigkeys

bash

redis-cli --bigkeys

它会扫描所有 key，按类型统计最大的 key。但注意：**会阻塞 Redis**，生产环境建议在从节点或低峰期执行。

### 2. MEMORY USAGE 命令

bash

MEMORY USAGE mykey

返回 key 及其值占用的字节数（近似值）。

### 3. 定期扫描脚本

python

import redis

r = redis.Redis()

cursor = 0

while True:

cursor, keys = r.scan(cursor=cursor, count=1000)

for key in keys:

size = r.memory_usage(key)

if size > 10 * 1024:  # > 10KB

print(f"BigKey: {key}, size={size}")

if cursor == 0:

break

### 4. 云服务商工具
- 阿里云 Redis 控制台提供“大 Key 分析”。
- 腾讯云 Redis 也有类似功能。

---

## 三、如何处理 BigKey？

### 方案1：拆分
- 将一个大 Hash 拆分为多个小 Hash（按业务维度分片）。
- 将一个大 List 拆分为多个 List（按时间或范围分片）。

**示例**：存储用户行为日志

bash

原来：一个 List 存储所有日志

LPUSH user:logs "event1" "event2" ...

拆分：按天分片

LPUSH user:logs:2025-01-01 "event1"

LPUSH user:logs:2025-01-02 "event2"

### 方案2：压缩
- 对 String 值使用压缩算法（如 gzip）后再存入。
- 使用更紧凑的数据结构（如 Hash 的 ziplist 编码）。

### 方案3：淘汰
- 对不需要的数据设置 TTL 自动过期。
- 使用 `LTRIM` 限制 List 长度。

### 方案4：异步删除

bash

Redis 4.0+ 提供 UNLINK 命令，后台异步回收内存

UNLINK bigkey

---

## 四、什么是 HotKey？

**HotKey** 是指在短时间内被大量访问的 key。例如：
- 热门商品的缓存 key。
- 大 V 的用户信息 key。
- 秒杀活动的库存 key。

### HotKey 的危害
- **单节点负载过高**：导致该节点 CPU 飙升、延迟增大。
- **集群数据倾斜**：集群中某个节点流量远高于其他节点。
- **缓存击穿**：如果 HotKey 恰好过期，大量请求打到数据库。

---

## 五、如何发现 HotKey？

### 1. redis-cli --hotkeys（Redis 4.0+）

bash

redis-cli --hotkeys

需要开启 `maxmemory-policy` 为 LFU 策略（如 `allkeys-lfu`），因为该命令依赖 LFU 计数器。

### 2. MONITOR 命令（慎用）

bash

redis-cli MONITOR | grep "GET hotkey"

MONITOR 会输出所有命令，高并发下会严重降低性能，仅用于临时调试。

### 3. 客户端统计
在客户端（如 Jedis、Lettuce）中埋点，统计每个 key 的访问次数。

### 4. 代理层统计
如果使用代理（如 Twemproxy），可以在代理层统计请求分布。

---

## 六、如何处理 HotKey？

### 方案1：本地缓存（客户端缓存）
在应用服务器内存中缓存热点数据，减少对 Redis 的访问。

java

// 使用 Caffeine 本地缓存

LoadingCache<String, Object> localCache = Caffeine.newBuilder()

.maximumSize(1000)

.expireAfterWrite(10, TimeUnit.SECONDS)

.build(key -> redisTemplate.opsForValue().get(key));

### 方案2：读写分离
- 主节点处理写请求，从节点处理读请求。
- 将 HotKey 的读请求分散到多个从节点。

### 方案3：副本分摊（Redis 4.0+）
在 Redis Cluster 中，可以为 HotKey 所在的槽添加只读副本，客户端可以读取副本。

### 方案4：二级缓存
- 第一级：本地缓存（如 Caffeine）。
- 第二级：Redis 集群。
- 第三级：数据库。

### 方案5：打散
- 将同一个 HotKey 复制为多个副本 key，如 `hotkey:1`、`hotkey:2`。
- 客户端随机选择其中一个副本读取。
- 更新时需要更新所有副本（写放大）。

**示例**：

java

// 写入时更新所有副本

for (int i = 0; i < 10; i++) {

redisTemplate.opsForValue().set("hotkey:" + i, value);

}

// 读取时随机选一个

int index = ThreadLocalRandom.current().nextInt(10);

String value = redisTemplate.opsForValue().get("hotkey:" + index);

### 方案6：限流与降级
- 对 HotKey 的访问进行限流（如令牌桶）。
- 超出限流的请求直接返回降级数据（如默认值）。

---

## 七、预防措施

- **设计阶段**：预估数据规模和访问热度，合理设计 key 结构。
- **代码审查**：避免对大 key 执行全量操作。
- **监控告警**：设置 BigKey 和 HotKey 的监控指标，及时预警。
- **容量规划**：定期评估 Redis 内存和 QPS 水位。

---

## 小结

- BigKey 导致阻塞和网络问题，应拆分或压缩。
- HotKey 导致节点过载，应使用本地缓存或副本分摊。
- 发现工具：`--bigkeys`、`--hotkeys`、`MEMORY USAGE`、客户端统计。
- 处理原则：**拆分、缓存、限流、监控**。