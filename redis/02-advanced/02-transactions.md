# Redis 事务与 Lua 脚本

Redis 提供了一种简单的事务机制，以及更强大的 Lua 脚本支持。理解它们的区别和使用场景非常重要。

---

## 一、Redis 事务

### 特点
- **批量执行**：将多个命令打包，按顺序一次性执行。
- **不支持回滚**：如果事务中某条命令语法错误，整个事务不执行；如果运行时错误（如对字符串执行 LPOP），其他命令仍会执行（部分成功）。
- **隔离性**：事务执行过程中，不会被其他客户端的命令打断（但 watch 机制可实现乐观锁）。

### 事务命令
| 命令 | 作用 |
|------|------|
| `MULTI` | 开启事务 |
| `EXEC` | 执行事务中的所有命令 |
| `DISCARD` | 取消事务 |
| `WATCH key [key...]` | 监视一个或多个键（乐观锁） |
| `UNWATCH` | 取消所有监视 |

### 示例

bash

127.0.0.1:6379> MULTI

OK

127.0.0.1:6379(TX)> SET balance 100

QUEUED

127.0.0.1:6379(TX)> DECRBY balance 20

QUEUED

127.0.0.1:6379(TX)> EXEC

OK

(integer) 80

### WATCH 实现乐观锁

bash

127.0.0.1:6379> WATCH balance

OK

127.0.0.1:6379> MULTI

OK

127.0.0.1:6379(TX)> DECRBY balance 30

QUEUED

127.0.0.1:6379(TX)> EXEC

(nil)  # 如果在 WATCH 之后 balance 被其他客户端修改，EXEC 返回 nil，事务放弃

### 事务的局限性
- 没有回滚，出现运行时错误只能部分执行。
- 无法根据前一条命令的结果决定是否执行后续命令（做不到“如果余额不足则不扣款”）。

---

## 二、Lua 脚本

### 为什么需要 Lua 脚本？
- **原子性**：整个脚本作为一个整体执行，要么全部成功，要么全部不执行（脚本执行期间不会插入其他命令）。
- **减少网络开销**：多条命令一次发送，一次返回。
- **逻辑控制**：可以在脚本中使用 if/else、循环等控制结构。

### EVAL 命令

bash

EVAL script numkeys key [key...] arg [arg...]

### 示例：转账（原子操作）

lua

-- 脚本内容

local from = KEYS[1]

local to = KEYS[2]

local amount = tonumber(ARGV[1])

local balance = redis.call('GET', from)

if not balance or tonumber(balance) < amount then

return -1  -- 余额不足

end

redis.call('DECRBY', from, amount)

redis.call('INCRBY', to, amount)

return 1  -- 成功

执行：

bash

EVAL "local from=KEYS[1];local to=KEYS[2];local amt=tonumber(ARGV[1]);local bal=redis.call('GET',from);if not bal or tonumber(bal)<amt then return -1 end;redis.call('DECRBY',from,amt);redis.call('INCRBY',to,amt);return 1" 2 account:a account:b 50

### 脚本缓存
- `SCRIPT LOAD script`：将脚本加载到缓存，返回 SHA1 校验和。
- `EVALSHA sha1 numkeys key [key...] arg [arg...]`：通过 SHA1 执行缓存的脚本（避免重复传输脚本内容）。

### Lua 脚本注意事项
- 脚本中应避免使用随机函数（如 `TIME`、`SRANDMEMBER`），否则可能导致主从不一致。
- 脚本执行时间不宜过长（默认 5 秒限制），否则会被强制终止并记录日志。
- 脚本中所有键应该提前声明在 KEYS 数组中，以便 Redis Cluster 进行哈希槽路由。

---

## 三、事务 vs Lua 脚本

| 对比维度 | Redis 事务 | Lua 脚本 |
|----------|------------|----------|
| 原子性 | 是（但不回滚运行时错误） | 是（完全原子） |
| 逻辑控制 | 不支持 | 支持 if/else、循环 |
| 回滚 | 不支持 | 脚本执行失败，所有写操作无效 |
| 性能 | 多条命令多次网络往返 | 一次网络往返 |
| 复杂度 | 简单 | 需要学习 Lua 语法 |
| 适用场景 | 简单的批量执行 | 复杂的原子操作 |

---

## 四、实际应用场景

### 场景1：分布式锁（SETNX + Lua 释放）

lua

-- 释放锁的 Lua 脚本（确保只有持有者才能释放）

if redis.call('GET', KEYS[1]) == ARGV[1] then

return redis.call('DEL', KEYS[1])

else

return 0

end

### 场景2：限流（滑动窗口）

lua

-- 限制每分钟最多 10 次

local key = KEYS[1]

local now = tonumber(ARGV[1])

local window = 60

local limit = 10

redis.call('ZREMRANGEBYSCORE', key, 0, now - window * 1000)

local count = redis.call('ZCARD', key)

if count >= limit then

return 0  -- 拒绝

end

redis.call('ZADD', key, now, now)

redis.call('EXPIRE', key, window)

return 1  -- 允许

---

## 小结

- Redis 事务适合简单的一批命令顺序执行，但不能回滚。
- Lua 脚本是实现复杂原子操作的推荐方式，在分布式锁、限流、计数器等场景广泛使用。
- 生产环境中尽量使用 Lua 脚本替代事务，以获得更好的原子性和灵活性。