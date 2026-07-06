# 缓存策略：穿透、击穿、雪崩解决方案

缓存是提升系统性能的利器，但也带来了缓存穿透、缓存击穿、缓存雪崩三大经典问题。

---

## 一、缓存穿透

### 问题描述
查询一个**不存在的数据**，由于缓存中没有，每次请求都会穿透到数据库，导致数据库压力剧增。恶意攻击者可以利用这一点发起大量查询不存在数据的请求。

### 解决方案

#### 方案1：缓存空值
将查询结果为 null 的数据也缓存起来，设置较短的 TTL（如 5 分钟）。

java

public Object getFromCache(String key) {

Object value = redisTemplate.opsForValue().get(key);

if (value != null) {

return value;

}

// 从数据库查询

Object dbValue = queryFromDB(key);

if (dbValue == null) {

// 缓存空值，TTL 60 秒

redisTemplate.opsForValue().set(key, NULL_VALUE, 60, TimeUnit.SECONDS);

} else {

redisTemplate.opsForValue().set(key, dbValue, 3600, TimeUnit.SECONDS);

}

return dbValue;

}

#### 方案2：布隆过滤器
在缓存前加一层布隆过滤器，判断 key 是否存在。不存在则直接返回，避免查询数据库。

java

// 初始化布隆过滤器（项目启动时加载所有存在的 key）

BloomFilter<String> bloomFilter = BloomFilter.create(Funnels.stringFunnel(), expectedInsertions, fpp);

// 查询时

if (!bloomFilter.mightContain(key)) {

return null; // 肯定不存在

}

// 再从缓存/数据库查询

#### 方案3：参数校验
对请求参数进行合法性校验，如 ID 必须为正整数、长度限制等。

---

## 二、缓存击穿

### 问题描述
一个**热点 key** 在缓存过期的瞬间，大量并发请求同时涌入，全部打到数据库，导致数据库压力激增。

### 解决方案

#### 方案1：互斥锁（Mutex Lock）
当缓存失效时，只允许一个线程去查询数据库并重建缓存，其他线程等待。

java

public Object getWithMutex(String key) {

Object value = redisTemplate.opsForValue().get(key);

if (value != null) {

return value;

}

// 尝试获取分布式锁

String lockKey = "lock:" + key;

String requestId = UUID.randomUUID().toString();

Boolean locked = redisTemplate.opsForValue()

.setIfAbsent(lockKey, requestId, 10, TimeUnit.SECONDS);

if (Boolean.TRUE.equals(locked)) {

try {

// 双重检查（避免其他线程已经重建了缓存）

value = redisTemplate.opsForValue().get(key);

if (value != null) {

return value;

}

// 查询数据库

value = queryFromDB(key);

redisTemplate.opsForValue().set(key, value, 3600, TimeUnit.SECONDS);

return value;

} finally {

// 释放锁（Lua 脚本保证原子性）

String script = "if redis.call('get', KEYS[1]) == ARGV[1] then return redis.call('del', KEYS[1]) else return 0 end";

redisTemplate.execute(new DefaultRedisScript<>(script, Long.class),

Collections.singletonList(lockKey), requestId);

}

} else {

// 等待并重试

try { Thread.sleep(50); } catch (InterruptedException e) {}

return getWithMutex(key); // 递归重试

}

}

#### 方案2：逻辑过期（永不过期 + 异步更新）
缓存不设置物理过期时间，而是在 value 中存储一个逻辑过期时间。查询时判断是否过期，如果过期则异步更新缓存，但返回旧数据。

java

public class CacheItem<T> {

private T data;

private long expireTime; // 逻辑过期时间戳

}

public T getWithLogicalExpire(String key) {

CacheItem<T> item = redisTemplate.opsForValue().get(key);

if (item == null) {

return queryFromDB(key);

}

if (System.currentTimeMillis() > item.getExpireTime()) {

// 异步更新缓存

threadPoolExecutor.submit(() -> {

String lockKey = "lock:" + key;

if (tryLock(lockKey)) {

try {

T newData = queryFromDB(key);

CacheItem<T> newItem = new CacheItem<>(newData, System.currentTimeMillis() + 3600_000);

redisTemplate.opsForValue().set(key, newItem);

} finally {

unlock(lockKey);

}

}

});

}

return item.getData(); // 返回旧数据

}

---

## 三、缓存雪崩

### 问题描述
大量缓存**在同一时间过期**，或者 Redis 宕机，导致所有请求涌向数据库。

### 解决方案

#### 方案1：均匀过期时间
设置不同的 TTL，避免集体失效。

java

// 在原有 TTL 基础上加上随机值

long ttl = 3600 + RandomUtil.randomLong(0, 600); // 1小时 ± 10分钟

redisTemplate.opsForValue().set(key, value, ttl, TimeUnit.SECONDS);

#### 方案2：多级缓存
本地缓存（Caffeine）+ Redis 缓存 + 数据库，层层防护。

#### 方案3：Redis 高可用
使用主从 + Sentinel 或 Cluster，避免单点故障。

#### 方案4：限流降级
在缓存失效时，对数据库的访问进行限流，超出部分返回降级数据（如默认值或错误提示）。

#### 方案5：提前预热
在业务低峰期提前将热点数据加载到缓存，并设置合理的过期时间。

---

## 四、缓存一致性

除了三大问题，还需要关注缓存与数据库的一致性：

| 策略 | 描述 | 适用场景 |
|------|------|----------|
| 先更新数据库，再删除缓存 | 更新 DB → 删除缓存 | 读多写少（推荐） |
| 先更新数据库，再更新缓存 | 更新 DB → 更新缓存 | 写操作频繁 |
| 先删除缓存，再更新数据库 | 删除缓存 → 更新 DB | 有脏读风险 |
| 延迟双删 | 删除缓存 → 更新 DB → 延迟再删缓存 | 高一致性要求 |

**推荐**：先更新数据库，再删除缓存。如果删除失败，可通过消息队列重试。

---

## 五、在苍穹外卖中的应用

苍穹外卖中缓存了菜品、套餐、店铺状态等数据，需要注意：

- 菜品更新时使用 `@CacheEvict` 清除对应缓存。
- 店铺状态缓存使用永不过期 + 主动更新（因为状态变更频率很低）。
- 分类缓存设置随机 TTL 避免雪崩。

---

## 小结

- 缓存穿透：缓存空值或布隆过滤器。
- 缓存击穿：互斥锁或逻辑过期。
- 缓存雪崩：均匀过期、多级缓存、高可用。
- 缓存一致性：先更新 DB 再删缓存。