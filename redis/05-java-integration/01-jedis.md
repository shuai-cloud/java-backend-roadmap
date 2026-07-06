# Jedis：Redis 的 Java 客户端

Jedis 是 Redis 官方推荐的 Java 客户端之一，轻量、简单、易用，支持同步、异步和连接池。

---

## 一、引入依赖
xml

<dependency>

<groupId>redis.clients</groupId>

<artifactId>jedis</artifactId>

<version>5.1.0</version>

</dependency>

纯文本
---

## 二、基本使用

### 1. 连接 Redis
java

// 无密码

Jedis jedis = new Jedis("localhost", 6379);

// 有密码

Jedis jedis = new Jedis("localhost", 6379);

jedis.auth("yourpassword");

// 使用 URI

Jedis jedis = new Jedis("redis://:password@localhost:6379/0");

纯文本
### 2. 基础 CRUD
java

// 字符串

jedis.set("name", "Alice");

String name = jedis.get("name");  // "Alice"

// 哈希

jedis.hset("user:1001", "name", "Bob");

jedis.hset("user:1001", "age", "30");

Map<String, String> user = jedis.hgetAll("user:1001");

// 列表

jedis.lpush("queue", "task1", "task2");

List<String> tasks = jedis.lrange("queue", 0, -1);

// 集合

jedis.sadd("tags", "java", "redis");

Set<String> tags = jedis.smembers("tags");

// 有序集合

jedis.zadd("leaderboard", 100, "player1");

Set<String> top = jedis.zrevrange("leaderboard", 0, 2);

纯文本
### 3. 设置过期时间
java

jedis.setex("code", 60, "123456");     // 60 秒后过期

jedis.expire("session", 3600);         // 设置已有 key 的过期时间

long ttl = jedis.ttl("session");       // 查看剩余时间

纯文本
### 4. 事务
java

Transaction tx = jedis.multi();

tx.set("key1", "value1");

tx.incr("counter");

List<Object> results = tx.exec();

纯文本
### 5. Pipeline（管道）
java

Pipeline pipeline = jedis.pipelined();

pipeline.set("key1", "val1");

pipeline.set("key2", "val2");

pipeline.incr("counter");

List<Object> responses = pipeline.syncAndReturnAll();

纯文本
---

## 三、连接池（JedisPool）

生产环境必须使用连接池，避免频繁创建和销毁连接。
java

// 创建连接池配置

JedisPoolConfig poolConfig = new JedisPoolConfig();

poolConfig.setMaxTotal(100);            // 最大连接数

poolConfig.setMaxIdle(20);              // 最大空闲连接数

poolConfig.setMinIdle(5);               // 最小空闲连接数

poolConfig.setMaxWaitMillis(3000);      // 获取连接最大等待时间（毫秒）

poolConfig.setTestOnBorrow(true);       // 获取连接时测试可用性

// 创建连接池

JedisPool jedisPool = new JedisPool(poolConfig, "localhost", 6379, 2000, "password");

// 使用连接池

try (Jedis jedis = jedisPool.getResource()) {

jedis.set("foo", "bar");

String value = jedis.get("foo");

}

// 关闭连接池（应用关闭时）

jedisPool.close();

纯文本
### 连接池参数说明

| 参数 | 说明 | 建议值 |
|------|------|--------|
| maxTotal | 最大连接数 | 根据并发量，通常 50~200 |
| maxIdle | 最大空闲连接数 | 一般为 maxTotal 的一半 |
| minIdle | 最小空闲连接数 | 5~10 |
| maxWaitMillis | 获取连接超时时间（ms） | 3000~5000 |
| testOnBorrow | 获取连接时验证 | true（生产环境） |
| testOnReturn | 归还连接时验证 | false |
| blockWhenExhausted | 连接池耗尽时是否阻塞 | true |

---

## 四、Jedis 与 Sentinel 集成
java

Set<String> sentinels = new HashSet<>();

sentinels.add("192.168.1.1:26379");

sentinels.add("192.168.1.2:26379");

sentinels.add("192.168.1.3:26379");

JedisSentinelPool pool = new JedisSentinelPool("mymaster", sentinels, poolConfig, "password");

try (Jedis jedis = pool.getResource()) {

jedis.set("key", "value");

}

纯文本
---

## 五、Jedis 与 Cluster 集成
java

Set<HostAndPort> nodes = new HashSet<>();

nodes.add(new HostAndPort("127.0.0.1", 7000));

nodes.add(new HostAndPort("127.0.0.1", 7001));

nodes.add(new HostAndPort("127.0.0.1", 7002));

JedisCluster jedisCluster = new JedisCluster(nodes, 2000, 2000, 5, "password", poolConfig);

jedisCluster.set("foo", "bar");

String value = jedisCluster.get("foo");

jedisCluster.close();

纯文本
---

## 六、注意事项

1. **线程安全**：Jedis 实例不是线程安全的，不要在多线程间共享同一个 Jedis 实例。使用 JedisPool 获取新实例。
2. **资源释放**：使用 try-with-resources 或在 finally 中调用 `close()` 归还连接到池。
3. **超时设置**：连接超时和读写超时建议设置合理值（通常 2~5 秒）。
4. **二进制安全**：Jedis 支持 byte[]，可用于存储序列化对象。

---

## 小结

- Jedis 是轻量级的 Redis Java 客户端，API 直观。
- 生产环境必须使用连接池（JedisPool）。
- 支持 Sentinel 和 Cluster 模式。
- 注意线程安全和资源释放。