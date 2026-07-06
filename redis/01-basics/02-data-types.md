# Redis 五大基本数据类型

Redis 支持五种基本数据类型：**String（字符串）、Hash（哈希）、List（列表）、Set（集合）、ZSet（有序集合）**。每种类型都有不同的内部编码和适用场景。

---

## 1. String（字符串）

### 特点
- 二进制安全，可以存储任何数据（文本、数字、图片 base64、序列化对象等）。
- 最大容量 512 MB。

### 常用命令
| 命令 | 作用 | 示例 |
|------|------|------|
| `SET key value` | 设置键值 | `SET name "Tom"` |
| `GET key` | 获取值 | `GET name` |
| `DEL key` | 删除键 | `DEL name` |
| `INCR key` | 自增 1（值必须是整数） | `INCR count` |
| `DECR key` | 自减 1 | `DECR count` |
| `INCRBY key increment` | 增加指定数值 | `INCRBY age 5` |
| `MSET key1 val1 key2 val2` | 批量设置 | `MSET a 1 b 2` |
| `MGET key1 key2` | 批量获取 | `MGET a b` |
| `STRLEN key` | 获取字符串长度 | `STRLEN name` |
| `APPEND key value` | 追加字符串 | `APPEND name " Smith"` |
| `SETEX key seconds value` | 设置值并指定过期时间（秒） | `SETEX code 60 "123456"` |
| `SETNX key value` | 只有键不存在时才设置（用于分布式锁） | `SETNX lock "1"` |

### 内部编码
- `int`：8 字节长整型
- `embstr`：小于等于 44 字节的字符串
- `raw`：大于 44 字节的字符串

### 应用场景
- **缓存**：存储 JSON 字符串。
- **计数器**：点赞、访问次数。
- **分布式锁**：SETNX + EXPIRE。
- **共享 Session**：存储用户登录态。

---

## 2. Hash（哈希）

### 特点
- 类似于 Java 的 `Map<String, String>`，适合存储对象（如用户信息）。
- 每个 Hash 最多可存储 2^32 - 1 个字段。

### 常用命令
| 命令 | 作用 | 示例 |
|------|------|------|
| `HSET key field value` | 设置字段值 | `HSET user:1001 name "Alice"` |
| `HGET key field` | 获取字段值 | `HGET user:1001 name` |
| `HMSET key f1 v1 f2 v2` | 批量设置字段 | `HMSET user:1001 age 25 city "NY"` |
| `HMGET key f1 f2` | 批量获取字段 | `HMGET user:1001 name age` |
| `HGETALL key` | 获取所有字段和值 | `HGETALL user:1001` |
| `HDEL key field` | 删除字段 | `HDEL user:1001 age` |
| `HEXISTS key field` | 判断字段是否存在 | `HEXISTS user:1001 name` |
| `HLEN key` | 获取字段数量 | `HLEN user:1001` |
| `HINCRBY key field increment` | 字段自增 | `HINCRBY user:1001 age 1` |
| `HKEYS key` | 获取所有字段名 | `HKEYS user:1001` |
| `HVALS key` | 获取所有值 | `HVALS user:1001` |

### 内部编码
- `ziplist`：字段少且值小时使用。
- `hashtable`：字段多或值大时使用。

### 应用场景
- **对象存储**：用户信息、商品详情。
- **购物车**：用户 ID 为 key，商品 ID 为 field，数量为 value。

---

## 3. List（列表）

### 特点
- 双向链表结构，支持两端插入/弹出。
- 有序，可重复。
- 最多 2^32 - 1 个元素。

### 常用命令
| 命令 | 作用 | 示例 |
|------|------|------|
| `LPUSH key value` | 左侧插入 | `LPUSH queue "task1"` |
| `RPUSH key value` | 右侧插入 | `RPUSH queue "task2"` |
| `LPOP key` | 左侧弹出并移除 | `LPOP queue` |
| `RPOP key` | 右侧弹出并移除 | `RPOP queue` |
| `LRANGE key start stop` | 获取范围内的元素 | `LRANGE queue 0 -1`（全部） |
| `LLEN key` | 获取列表长度 | `LLEN queue` |
| `LINDEX key index` | 获取指定索引的元素 | `LINDEX queue 0` |
| `LSET key index value` | 修改指定索引的值 | `LSET queue 0 "new_task"` |
| `LREM key count value` | 删除指定值的元素 | `LREM queue 2 "task1"` |
| `BLPOP key timeout` | 阻塞式左侧弹出 | `BLPOP queue 5`（等待5秒） |
| `BRPOP key timeout` | 阻塞式右侧弹出 | `BRPOP queue 5` |

### 内部编码
- `quicklist`：由多个 ziplist 组成的链表。

### 应用场景
- **消息队列**：LPUSH + BRPOP 实现生产者-消费者。
- **最新消息/文章列表**：LPUSH 新消息，LRANGE 获取前 N 条。
- **栈**：LPUSH + LPOP。
- **队列**：RPUSH + LPOP。

---

## 4. Set（集合）

### 特点
- 无序、不可重复。
- 支持交集、并集、差集运算。
- 最多 2^32 - 1 个元素。

### 常用命令
| 命令 | 作用 | 示例 |
|------|------|------|
| `SADD key member` | 添加元素 | `SADD tags "java"` |
| `SMEMBERS key` | 获取所有元素 | `SMEMBERS tags` |
| `SISMEMBER key member` | 判断元素是否存在 | `SISMEMBER tags "java"` |
| `SCARD key` | 获取元素个数 | `SCARD tags` |
| `SREM key member` | 删除元素 | `SREM tags "python"` |
| `SPOP key [count]` | 随机弹出元素 | `SPOP tags 2` |
| `SRANDMEMBER key [count]` | 随机获取元素（不移除） | `SRANDMEMBER tags 3` |
| `SINTER key1 key2` | 求交集 | `SINTER set1 set2` |
| `SUNION key1 key2` | 求并集 | `SUNION set1 set2` |
| `SDIFF key1 key2` | 求差集（key1 - key2） | `SDIFF set1 set2` |

### 内部编码
- `intset`：元素全是整数且数量少时。
- `hashtable`：元素非整数或数量多时。

### 应用场景
- **标签系统**：用户兴趣标签、文章标签。
- **共同好友**：SINTER 求交集。
- **抽奖**：SPOP 随机抽取。
- **关注/粉丝**：用户 ID 集合。

---

## 5. ZSet（有序集合）

### 特点
- 每个元素关联一个 **score（分数）**，按 score 排序。
- 元素唯一，score 可重复。
- 支持范围查询、排名操作。

### 常用命令
| 命令 | 作用 | 示例 |
|------|------|------|
| `ZADD key score member` | 添加元素 | `ZADD leaderboard 100 "player1"` |
| `ZRANGE key start stop [WITHSCORES]` | 按 score 升序获取元素 | `ZRANGE leaderboard 0 -1 WITHSCORES` |
| `ZREVRANGE key start stop [WITHSCORES]` | 按 score 降序获取元素 | `ZREVRANGE leaderboard 0 -1` |
| `ZRANK key member` | 获取元素排名（升序，从0开始） | `ZRANK leaderboard "player1"` |
| `ZREVRANK key member` | 获取元素排名（降序） | `ZREVRANK leaderboard "player1"` |
| `ZSCORE key member` | 获取元素的分数 | `ZSCORE leaderboard "player1"` |
| `ZCARD key` | 获取元素个数 | `ZCARD leaderboard` |
| `ZCOUNT key min max` | 统计分数在区间内的元素个数 | `ZCOUNT leaderboard 50 100` |
| `ZREM key member` | 删除元素 | `ZREM leaderboard "player2"` |
| `ZINCRBY key increment member` | 增加元素的分数 | `ZINCRBY leaderboard 10 "player1"` |
| `ZRANGEBYSCORE key min max [LIMIT offset count]` | 按分数范围获取元素 | `ZRANGEBYSCORE leaderboard 60 100` |
| `ZREMRANGEBYRANK key start stop` | 删除指定排名范围的元素 | `ZREMRANGEBYRANK leaderboard 0 99` |

### 内部编码
- `ziplist`：元素少且分数/成员长度短时。
- `skiplist`：元素多时（跳跃表 + 字典）。

### 应用场景
- **排行榜**：游戏积分、销售额排名。
- **延迟队列**：将任务执行时间作为 score，轮询 ZRANGEBYSCORE 取出到期任务。
- **限流**：滑动窗口算法（score 为时间戳）。
- **权重队列**：按优先级处理任务。

---

## 数据类型选择速查表

| 需求 | 推荐类型 | 原因 |
|------|----------|------|
| 缓存简单值（JSON、HTML） | String | 简单高效 |
| 存储对象（用户、商品） | Hash | 支持单独修改字段 |
| 消息队列 | List | 阻塞操作、FIFO |
| 去重、交集、并集 | Set | 集合运算 |
| 排行榜、延时任务 | ZSet | 排序、范围查询 |
| 计数器 | String | INCR/DECR |
| 地理位置 | GEO（基于ZSet） | 距离计算、附近的人 |

---

## 小结

- 五种基本数据类型各有特点，选择合适的数据类型是 Redis 优化的关键。
- 掌握常用命令，特别是与业务场景相关的命令（如 ZSet 的范围查询、Set 的交集运算）。
- 内部编码有助于理解内存优化（如 ziplist 比 hashtable 节省内存）。