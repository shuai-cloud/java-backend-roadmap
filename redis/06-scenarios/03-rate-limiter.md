# 限流

限流是保护系统不被突发流量冲垮的重要手段。Redis 可以高效地实现多种限流算法。

---

## 一、常见的限流算法

| 算法 | 原理 | 特点 |
|------|------|------|
| 固定窗口 | 统计单位时间内的请求数，超过阈值则拒绝 | 实现简单，但存在临界突变问题 |
| 滑动窗口 | 将时间划分为更小的格子，滑动统计 | 更平滑，但内存占用稍高 |
| 令牌桶 | 匀速产生令牌，请求消耗令牌 | 允许一定程度的突发流量 |
| 漏桶 | 请求以固定速率流出，超出则丢弃 | 强制平滑流量 |

---

## 二、基于 Redis 的滑动窗口限流

### 原理

使用 ZSet 存储每个请求的时间戳，score 为时间戳，value 可以是请求 ID 或时间戳本身。统计窗口内的元素个数。

### Lua 脚本实现

lua

-- 限流脚本：每分钟最多 10 次

local key = KEYS[1]           -- 限流 key，如 "ratelimit:api:/order"

local now = tonumber(ARGV[1]) -- 当前时间戳（毫秒）

local window = tonumber(ARGV[2]) -- 窗口大小（毫秒），如 60000

local limit = tonumber(ARGV[3])  -- 最大请求数

-- 移除窗口外的旧数据

redis.call('ZREMRANGEBYSCORE', key, 0, now - window)

-- 统计当前窗口内的请求数

local count = redis.call('ZCARD', key)

if count >= limit then

return 0  -- 拒绝

end

-- 记录本次请求

redis.call('ZADD', key, now, now)

redis.call('EXPIRE', key, window / 1000)  -- 设置过期时间（秒）

return 1  -- 允许

### Java 调用

java

public boolean tryAcquire(String key, int limit, long windowMs) {

String script = "..."; // 上面的 Lua 脚本

Long result = redisTemplate.execute(

new DefaultRedisScript<>(script, Long.class),

Collections.singletonList(key),

String.valueOf(System.currentTimeMillis()),

String.valueOf(windowMs),

String.valueOf(limit)

);

return Long.valueOf(1).equals(result);

}

---

## 三、基于令牌桶的限流

### 原理

- 令牌以固定速率放入桶中。
- 每个请求消耗一个令牌。
- 桶满则不再放令牌。
- 允许突发流量（桶的容量）。

### Redis 实现（使用 Hash）

lua

-- 令牌桶限流

local key = KEYS[1]

local rate = tonumber(ARGV[1])     -- 每秒生成令牌数

local capacity = tonumber(ARGV[2]) -- 桶容量

local now = tonumber(ARGV[3])      -- 当前时间戳（秒）

local requested = tonumber(ARGV[4]) -- 请求消耗的令牌数

local lastRefillTime = redis.call('HGET', key, 'lastRefillTime')

local tokens = redis.call('HGET', key, 'tokens')

if lastRefillTime == false then

lastRefillTime = now

tokens = capacity

else

lastRefillTime = tonumber(lastRefillTime)

tokens = tonumber(tokens)

end

-- 计算需要补充的令牌

local elapsed = math.max(0, now - lastRefillTime)

local refillTokens = elapsed * rate

tokens = math.min(capacity, tokens + refillTokens)

if tokens >= requested then

tokens = tokens - requested

redis.call('HMSET', key, 'tokens', tokens, 'lastRefillTime', now)

redis.call('EXPIRE', key, math.ceil(capacity / rate) + 1)

return 1  -- 允许

else

return 0  -- 拒绝

end

---

## 四、Redisson 的限流器

Redisson 内置了 `RRateLimiter`，基于令牌桶实现。

java

@Autowired

private RedissonClient redissonClient;

public boolean tryAcquire() {

RRateLimiter rateLimiter = redissonClient.getRateLimiter("myLimiter");

// 设置速率：每秒 10 个令牌

rateLimiter.trySetRate(RateType.OVERALL, 10, 1, RateIntervalUnit.SECONDS);

return rateLimiter.tryAcquire();

}

---

## 五、限流的应用场景

- **API 限流**：防止恶意爬虫或突发流量。
- **登录限流**：防止暴力破解密码。
- **下单限流**：防止秒杀活动中的超卖。
- **短信验证码限流**：防止滥用。

---

## 六、注意事项

1. **分布式限流**：使用 Redis 作为中心化存储，所有实例共享限流状态。
2. **性能**：限流操作应尽可能快，使用 Lua 脚本保证原子性。
3. **降级**：当 Redis 不可用时，限流应降级为本地限流或直接放行（避免雪崩）。
4. **监控**：记录被限流的请求数，用于调整阈值。

---

## 小结

- Redis 是实现分布式限流的理想工具，支持滑动窗口、令牌桶等算法。
- 使用 Lua 脚本保证原子性和性能。
- Redisson 提供了开箱即用的限流器。
- 限流是系统自我保护的重要手段。