# Redisson：分布式对象与服务框架

Redisson 是一个功能丰富的 Redis Java 客户端，提供了许多分布式数据结构和服务（如分布式锁、信号量、原子累加器等），极大地简化了分布式应用的开发。

---

## 一、引入依赖
xml

<dependency>

<groupId>org.redisson</groupId>

<artifactId>redisson-spring-boot-starter</artifactId>

<version>3.27.0</version>

</dependency>

纯文本
或单独使用：
xml

<dependency>

<groupId>org.redisson</groupId>

<artifactId>redisson</artifactId>

<version>3.27.0</version>

</dependency>

纯文本
---

## 二、配置 Redisson

### 1. 编程式配置
java

Config config = new Config();

config.useSingleServer()

.setAddress("redis://localhost:6379")

.setPassword("password")

.setConnectionPoolSize(100);

RedissonClient redisson = Redisson.create(config);

纯文本
### 2. 文件配置（redisson.yml）
yaml

singleServerConfig:

address: "redis://localhost:6379"

password: password

connectionPoolSize: 100

codec: org.redisson.codec.JsonJacksonCodec

纯文本
加载：
java

RedissonClient redisson = Redisson.create(Config.fromYAML(new File("redisson.yml")));

纯文本
### 3. Spring Boot 配置（application.yml）
yaml

spring:

redis:

redisson:

config: classpath:redisson.yml

纯文本
---

## 三、核心功能

### 1. 分布式锁
java

RLock lock = redisson.getLock("myLock");

// 加锁（最多等待 10 秒，锁定后 30 秒自动解锁）

boolean locked = lock.tryLock(10, 30, TimeUnit.SECONDS);

if (locked) {

try {

// 执行业务逻辑

} finally {

lock.unlock();

}

}

纯文本
Redisson 的锁是**可重入**的，支持自动续期（看门狗机制，默认每 10 秒续期一次）。

### 2. 分布式集合
java

RMap<String, String> map = redisson.getMap("myMap");

map.put("key1", "value1");

RSet<String> set = redisson.getSet("mySet");

set.add("element");

RList<String> list = redisson.getList("myList");

list.add("item");

纯文本
### 3. 分布式计数器和累加器
java

RAtomicLong counter = redisson.getAtomicLong("visits");

counter.incrementAndGet();  // 自增

RLongAdder adder = redisson.getLongAdder("total");

adder.add(10);

long sum = adder.sum();

纯文本
### 4. 分布式信号量
java

RSemaphore semaphore = redisson.getSemaphore("mySemaphore");

semaphore.tryAcquire(1, 10, TimeUnit.SECONDS);

semaphore.release();

纯文本
### 5. 分布式队列
java

RQueue<String> queue = redisson.getQueue("myQueue");

queue.offer("task1");

String task = queue.poll();

// 阻塞队列

RBlockingQueue<String> blockingQueue = redisson.getBlockingQueue("blockingQueue");

blockingQueue.offer("task");

blockingQueue.take();  // 阻塞直到有元素

纯文本
### 6. 分布式限流器
java

RRateLimiter rateLimiter = redisson.getRateLimiter("myLimiter");

rateLimiter.trySetRate(RateType.OVERALL, 10, 1, RateIntervalUnit.SECONDS);

if (rateLimiter.tryAcquire()) {

// 允许通过

}

纯文本
---

## 四、Redisson 与 Spring Cache 集成

Redisson 可以作为 Spring Cache 的底层实现：
java

@Configuration

public class RedissonCacheConfig {

@Bean

public CacheManager cacheManager(RedissonClient redissonClient) {

Map<String, CacheConfig> config = new HashMap<>();

config.put("products", new CacheConfig(24 * 60 * 60 * 1000, 12 * 60 * 60 * 1000)); // ttl 24h, max idle 12h

return new RedissonSpringCacheManager(redissonClient, config);

}

}

纯文本
---

## 五、Redisson 的优势

- **丰富的分布式对象**：锁、信号量、队列、限流器等开箱即用。
- **自动续期**：分布式锁的看门狗机制，避免死锁。
- **可重入锁**：同一个线程可多次加锁。
- **高可用**：支持 Sentinel 和 Cluster 模式。
- **序列化**：支持 Jackson、Kryo、Protobuf 等多种编码。

---

## 六、注意事项

1. **锁的粒度**：尽量缩小锁的范围，避免长时间持有锁。
2. **看门狗超时**：默认 30 秒，如果业务执行超过 30 秒，Redisson 会自动续期。但建议设置合理的 `leaseTime`。
3. **Redisson 版本**：与 Redis 版本兼容，建议使用最新稳定版。

---

## 小结

- Redisson 提供了比 Jedis/Lettuce 更高层次的抽象，适合需要分布式协调功能的项目。
- 分布式锁、限流器、队列等功能极大简化了分布式系统的开发。
- 在苍穹外卖中，可以使用 Redisson 的分布式锁防止重复下单。
