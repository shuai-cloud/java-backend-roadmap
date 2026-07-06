# 分布式锁

在分布式系统中，多个进程或线程需要互斥访问共享资源时，就需要分布式锁。Redis 是实现分布式锁的常用工具。

---

## 一、为什么需要分布式锁？

- 防止重复下单（同一用户短时间内多次点击）。
- 防止库存超卖（多个实例同时扣减库存）。
- 定时任务互斥（只让一个实例执行）。
- 分布式事务协调。

---

## 二、基于 SETNX 的简易分布式锁

### 原理

利用 Redis 的 `SETNX` 命令（SET if Not eXists），当 key 不存在时设置成功返回 1，否则返回 0。

### 基本实现

java

public boolean tryLock(String key, String requestId, long expireMs) {

// SET key value NX PX expireMs

String result = redisTemplate.opsForValue()

.setIfAbsent(key, requestId, expireMs, TimeUnit.MILLISECONDS);

return Boolean.TRUE.equals(result);

}

public boolean releaseLock(String key, String requestId) {

// 使用 Lua 脚本确保原子性：只有持有者才能释放

String script = "if redis.call('get', KEYS[1]) == ARGV[1] then " +

"return redis.call('del', KEYS[1]) else return 0 end";

Long result = redisTemplate.execute(

new DefaultRedisScript<>(script, Long.class),

Collections.singletonList(key), requestId);

return Long.valueOf(1).equals(result);

}

### 使用

java

String lockKey = "lock:order:" + userId;

String requestId = UUID.randomUUID().toString();

if (tryLock(lockKey, requestId, 3000)) {

try {

// 执行业务逻辑

} finally {

releaseLock(lockKey, requestId);

}

} else {

// 获取锁失败，返回提示

}

### 存在的问题

- **不可重入**：同一线程无法再次获取已持有的锁。
- **无自动续期**：如果业务执行时间超过过期时间，锁会被自动释放，导致其他线程获取锁。
- **主从切换可能导致锁丢失**：主节点宕机后，从节点未同步锁信息。

---

## 三、Redisson 分布式锁（推荐）

Redisson 提供了完善的分布式锁实现，解决了上述问题。

### 1. 引入依赖

xml

<dependency>

<groupId>org.redisson</groupId>

<artifactId>redisson-spring-boot-starter</artifactId>

<version>3.27.0</version>

</dependency>

### 2. 使用

java

@Autowired

private RedissonClient redissonClient;

public void processOrder(Long orderId) {

RLock lock = redissonClient.getLock("lock:order:" + orderId);

try {

// 尝试加锁，最多等待 10 秒，锁定后 30 秒自动解锁

if (lock.tryLock(10, 30, TimeUnit.SECONDS)) {

// 执行业务逻辑

}

} catch (InterruptedException e) {

Thread.currentThread().interrupt();

} finally {

if (lock.isHeldByCurrentThread()) {

lock.unlock();

}

}

}

### 3. Redisson 锁的特性

- **可重入**：同一线程可多次加锁，需对应次数解锁。
- **自动续期**（看门狗）：默认每 10 秒检查一次，如果业务未完成，自动续期 30 秒。
- **公平锁**：`redissonClient.getFairLock("lock:xxx")` 保证先到先得。
- **红锁（RedLock）**：用于跨多个 Redis 实例的高可靠锁。

---

## 四、分布式锁的注意事项

1. **锁的粒度**：尽量细粒度（如按用户 ID、订单 ID），避免锁住整个资源。
2. **超时时间**：设置合理的过期时间，避免死锁。
3. **释放锁**：务必在 finally 中释放，且只释放自己持有的锁。
4. **时钟漂移**：多节点环境下，不同机器的系统时间可能不一致，影响锁的过期判断（RedLock 对此有改进）。
5. **性能**：加锁和解锁都有网络开销，避免在锁内执行耗时操作。

---

## 五、在苍穹外卖中的应用

防止用户重复下单：

java

public Result submitOrder(OrdersSubmitDTO dto) {

String lockKey = "lock:order:" + dto.getUserId();

RLock lock = redissonClient.getLock(lockKey);

try {

if (lock.tryLock(3, 10, TimeUnit.SECONDS)) {

// 检查是否已有未支付的订单（幂等性校验）

// 创建订单...

return Result.success();

} else {

return Result.error("请勿重复提交订单");

}

} catch (InterruptedException e) {

return Result.error("系统繁忙");

} finally {

if (lock.isHeldByCurrentThread()) {

lock.unlock();

}

}

}

---

## 小结

- 分布式锁是分布式系统的必备组件，Redis 是实现它的优秀选择。
- 简单场景可使用 SETNX + Lua 脚本，生产环境推荐 Redisson。
- 注意锁的粒度、超时、可重入性和自动续期。