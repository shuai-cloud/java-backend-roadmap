# Redis 常用命令速查

本文档整理了 Redis 最常用的命令，按功能分类，方便日常查阅。

---

## 一、通用命令（所有数据类型通用）

| 命令 | 作用 | 示例 |
|------|------|------|
| `KEYS pattern` | 查找所有匹配模式的键（生产环境慎用） | `KEYS user:*` |
| `EXISTS key` | 判断键是否存在 | `EXISTS name` |
| `TYPE key` | 返回键的类型 | `TYPE name` |
| `DEL key [key...]` | 删除键 | `DEL name age` |
| `EXPIRE key seconds` | 设置键的过期时间（秒） | `EXPIRE session 3600` |
| `TTL key` | 查看剩余存活时间（秒） | `TTL session` |
| `PERSIST key` | 移除过期时间 | `PERSIST session` |
| `RENAME key newkey` | 重命名键 | `RENAME old_name new_name` |
| `RANDOMKEY` | 随机返回一个键 | `RANDOMKEY` |
| `DUMP key` | 序列化键的值 | `DUMP user:1` |
| `MIGRATE host port key\|"" destination-db timeout [COPY] [REPLACE]` | 迁移键到另一台 Redis | 详见官方文档 |
| `SCAN cursor [MATCH pattern] [COUNT count]` | 增量迭代键（替代 KEYS） | `SCAN 0 MATCH user:* COUNT 100` |

---

## 二、String 类型命令

| 命令 | 作用 |
|------|------|
| `SET key value [NX\|XX] [EX seconds] [PX milliseconds]` | 设置值（支持 NX/XX 条件，EX/PX 过期） |
| `GET key` | 获取值 |
| `GETSET key value` | 设置新值并返回旧值 |
| `MSET key value [key value...]` | 批量设置 |
| `MGET key [key...]` | 批量获取 |
| `INCR key` | 自增 1 |
| `INCRBY key increment` | 增加指定数值 |
| `DECR key` | 自减 1 |
| `DECRBY key decrement` | 减少指定数值 |
| `INCRBYFLOAT key increment` | 浮点数自增 |
| `APPEND key value` | 追加字符串 |
| `STRLEN key` | 获取字符串长度 |
| `SETEX key seconds value` | 设置值并指定过期时间（秒） |
| `SETNX key value` | 键不存在时设置（返回 1 成功，0 失败） |
| `SETRANGE key offset value` | 覆盖字符串的一部分 |
| `GETRANGE key start end` | 获取子串 |

---

## 三、Hash 类型命令

| 命令 | 作用 |
|------|------|
| `HSET key field value` | 设置字段值 |
| `HGET key field` | 获取字段值 |
| `HMSET key field value [field value...]` | 批量设置字段 |
| `HMGET key field [field...]` | 批量获取字段 |
| `HGETALL key` | 获取所有字段和值 |
| `HDEL key field [field...]` | 删除字段 |
| `HEXISTS key field` | 判断字段是否存在 |
| `HLEN key` | 获取字段数量 |
| `HKEYS key` | 获取所有字段名 |
| `HVALS key` | 获取所有值 |
| `HINCRBY key field increment` | 字段自增整数 |
| `HINCRBYFLOAT key field increment` | 字段自增浮点数 |
| `HSETNX key field value` | 字段不存在时设置 |
| `HSTRLEN key field` | 获取字段值的长度 |

---

## 四、List 类型命令

| 命令 | 作用 |
|------|------|
| `LPUSH key value [value...]` | 左侧插入一个或多个元素 |
| `RPUSH key value [value...]` | 右侧插入一个或多个元素 |
| `LPOP key` | 左侧弹出并移除 |
| `RPOP key` | 右侧弹出并移除 |
| `LRANGE key start stop` | 获取范围内元素（0 开始，-1 表示最后一个） |
| `LINDEX key index` | 获取指定索引元素 |
| `LSET key index value` | 修改指定索引的值 |
| `LINSERT key BEFORE\|AFTER pivot value` | 在某个值之前或之后插入 |
| `LLEN key` | 获取列表长度 |
| `LREM key count value` | 删除指定值的元素（count >0 从左往右删，<0 从右往左删，=0 删所有） |
| `LTRIM key start stop` | 截断列表，只保留指定范围 |
| `RPOPLPUSH source destination` | 将源列表右侧元素弹出并推入目标列表左侧 |
| `BLPOP key [key...] timeout` | 阻塞式左侧弹出（timeout 秒，0 无限等待） |
| `BRPOP key [key...] timeout` | 阻塞式右侧弹出 |
| `BRPOPLPUSH source destination timeout` | 阻塞式 RPOPLPUSH |

---

## 五、Set 类型命令

| 命令 | 作用 |
|------|------|
| `SADD key member [member...]` | 添加一个或多个元素 |
| `SMEMBERS key` | 获取所有元素 |
| `SISMEMBER key member` | 判断元素是否存在 |
| `SCARD key` | 获取元素个数 |
| `SREM key member [member...]` | 删除元素 |
| `SPOP key [count]` | 随机弹出 count 个元素 |
| `SRANDMEMBER key [count]` | 随机获取 count 个元素（不移除） |
| `SMOVE source destination member` | 将元素从一个集合移动到另一个集合 |
| `SINTER key [key...]` | 求交集 |
| `SINTERSTORE destination key [key...]` | 求交集并存入新集合 |
| `SUNION key [key...]` | 求并集 |
| `SUNIONSTORE destination key [key...]` | 求并集并存入新集合 |
| `SDIFF key [key...]` | 求差集 |
| `SDIFFSTORE destination key [key...]` | 求差集并存入新集合 |
| `SSCAN key cursor [MATCH pattern] [COUNT count]` | 增量迭代集合元素 |

---

## 六、ZSet 类型命令

| 命令 | 作用 |
|------|------|
| `ZADD key [NX\|XX] [GT\|LT] [CH] [INCR] score member [score member...]` | 添加或更新元素 |
| `ZRANGE key start stop [WITHSCORES]` | 按 score 升序获取元素 |
| `ZREVRANGE key start stop [WITHSCORES]` | 按 score 降序获取元素 |
| `ZRANGEBYSCORE key min max [WITHSCORES] [LIMIT offset count]` | 按分数范围获取元素 |
| `ZREVRANGEBYSCORE key max min [WITHSCORES] [LIMIT offset count]` | 按分数范围降序获取 |
| `ZRANK key member` | 获取元素排名（升序，0 开始） |
| `ZREVRANK key member` | 获取元素排名（降序） |
| `ZSCORE key member` | 获取元素分数 |
| `ZCARD key` | 获取元素个数 |
| `ZCOUNT key min max` | 统计分数区间内的元素个数 |
| `ZREM key member [member...]` | 删除元素 |
| `ZREMRANGEBYRANK key start stop` | 删除指定排名范围的元素 |
| `ZREMRANGEBYSCORE key min max` | 删除指定分数范围的元素 |
| `ZINCRBY key increment member` | 增加元素的分数 |
| `ZINTERSTORE destination numkeys key [key...] [WEIGHTS weight] [AGGREGATE SUM\|MIN\|MAX]` | 求交集并存入 |
| `ZUNIONSTORE destination numkeys key [key...] [WEIGHTS weight] [AGGREGATE SUM\|MIN\|MAX]` | 求并集并存入 |
| `ZSCAN key cursor [MATCH pattern] [COUNT count]` | 增量迭代有序集合 |

---

## 七、HyperLogLog 与 GEO

### HyperLogLog（基数统计）
| 命令 | 作用 |
|------|------|
| `PFADD key element [element...]` | 添加元素 |
| `PFCOUNT key [key...]` | 估算基数（不重复元素个数） |
| `PFMERGE destkey sourcekey [sourcekey...]` | 合并多个 HyperLogLog |

### GEO（地理位置）
| 命令 | 作用 |
|------|------|
| `GEOADD key longitude latitude member [longitude latitude member...]` | 添加地理坐标 |
| `GEOPOS key member [member...]` | 获取坐标 |
| `GEODIST key member1 member2 [unit]` | 计算距离（m/km/mi/ft） |
| `GEORADIUS key longitude latitude radius unit [WITHCOORD] [WITHDIST] [WITHHASH] [COUNT count] [ASC\|DESC]` | 查找半径内的元素 |
| `GEORADIUSBYMEMBER key member radius unit [...]` | 以某元素为中心查找半径内的元素 |
| `GEOHASH key member [member...]` | 获取 Geohash 字符串 |

---

## 八、事务与脚本

### 事务
| 命令 | 作用 |
|------|------|
| `MULTI` | 开启事务 |
| `EXEC` | 执行事务中的所有命令 |
| `DISCARD` | 取消事务 |
| `WATCH key [key...]` | 监视键（乐观锁） |
| `UNWATCH` | 取消监视 |

### Lua 脚本
| 命令 | 作用 |
|------|------|
| `EVAL script numkeys key [key...] arg [arg...]` | 执行 Lua 脚本 |
| `EVALSHA sha1 numkeys key [key...] arg [arg...]` | 执行缓存的脚本 |
| `SCRIPT LOAD script` | 加载脚本到缓存 |
| `SCRIPT EXISTS sha1 [sha1...]` | 检查脚本是否存在 |
| `SCRIPT FLUSH` | 清空脚本缓存 |
| `SCRIPT KILL` | 杀死正在执行的脚本 |

---

## 九、服务器管理命令

| 命令 | 作用 |
|------|------|
| `PING` | 测试连接是否正常 |
| `ECHO message` | 打印消息 |
| `SELECT index` | 切换数据库（0-15） |
| `FLUSHDB` | 清空当前数据库 |
| `FLUSHALL` | 清空所有数据库 |
| `DBSIZE` | 返回当前数据库的键数量 |
| `INFO [section]` | 获取服务器信息（如 memory、stats） |
| `CONFIG GET parameter` | 获取配置参数 |
| `CONFIG SET parameter value` | 修改配置参数（无需重启） |
| `CLIENT LIST` | 列出所有客户端连接 |
| `CLIENT KILL ip:port` | 杀死指定客户端连接 |
| `SHUTDOWN [NOSAVE\|SAVE]` | 关闭服务器 |
| `MONITOR` | 实时监控所有命令（调试用） |

---

## 十、键空间通知与慢查询

### 键空间通知
| 命令 | 作用 |
|------|------|
| `CONFIG SET notify-keyspace-events KEA` | 开启所有事件通知 |
| `PSUBSCRIBE __keyevent@0__:expired` | 订阅过期事件 |

### 慢查询日志
| 命令 | 作用 |
|------|------|
| `SLOWLOG GET [n]` | 获取最近 n 条慢查询 |
| `SLOWLOG LEN` | 获取慢查询日志长度 |
| `SLOWLOG RESET` | 重置慢查询日志 |
| `CONFIG SET slowlog-log-slower-than 10000` | 设置慢查询阈值（微秒） |
| `CONFIG SET slowlog-max-len 128` | 设置最大日志条数 |

---

## 小结

- 不必死记硬背所有命令，重点掌握 **五大数据类型的核心命令** 和 **通用命令**。
- 面试高频命令：`SETNX`（分布式锁）、`ZRANGE`（排行榜）、`BLPOP`（消息队列）、`SINTER`（共同好友）、`INCR`（计数器）。
- 实际开发中多用 `SCAN` 代替 `KEYS`，避免阻塞。
