# Lettuce：基于 Netty 的 Redis 客户端

Lettuce 是一个高性能的 Redis Java 客户端，基于 Netty 实现，支持同步、异步和响应式编程。它是 Spring Boot 2.x 默认的 Redis 客户端。

---

## 一、引入依赖
xml

<dependency>

<groupId>io.lettuce</groupId>

<artifactId>lettuce-core</artifactId>

<version>6.3.2.RELEASE</version>

</dependency>

纯文本
---

## 二、基本使用

### 1. 连接 Redis
java

// 单机

RedisClient client = RedisClient.create("redis://password@localhost:6379/0");

StatefulRedisConnection<String, String> connection = client.connect();

RedisCommands<String, String> commands = connection.sync();

// 或使用 URI 构建器

RedisURI uri = RedisURI.Builder

.redis("localhost", 6379)

.withPassword("password".toCharArray())

.withDatabase(0)

.build();

RedisClient client = RedisClient.create(uri);

纯文本
### 2. 基础 CRUD
java

// 同步

commands.set("name", "Alice");

String name = commands.get("name");

// 哈希

commands.hset("user:1001", "name", "Bob");

Map<String, String> user = commands.hgetall("user:1001");

// 列表

commands.lpush("queue", "task1");

List<String> tasks = commands.lrange("queue", 0, -1);

纯文本
### 3. 异步操作
java

RedisAsyncCommands<String, String> async = connection.async();

RedisFuture<String> future = async.get("name");

future.thenAccept(value -> System.out.println("Got: " + value));

// 等待所有异步操作完成

LettuceFutures.awaitAll(5, TimeUnit.SECONDS, future);

纯文本
### 4. 响应式（Reactive）
java

RedisReactiveCommands<String, String> reactive = connection.reactive();

reactive.get("name").subscribe(value -> System.out.println("Reactive got: " + value));

纯文本
---

## 三、连接池

Lettuce 的连接池基于 Apache Commons Pool2。
java

// 创建连接池配置

GenericObjectPoolConfig<StatefulRedisConnection<String, String>> poolConfig = new GenericObjectPoolConfig<>();

poolConfig.setMaxTotal(100);

poolConfig.setMaxIdle(20);

poolConfig.setMinIdle(5);

// 创建连接池

RedisClient client = RedisClient.create("redis://localhost:6379");

ConnectionPoolSupport.createGenericObjectPool(() -> client.connect(), poolConfig);

// 使用

try (StatefulRedisConnection<String, String> conn = pool.borrowObject()) {

RedisCommands<String, String> cmd = conn.sync();

cmd.set("key", "value");

}

纯文本
---

## 四、Sentinel 集成
java

RedisURI redisUri = RedisURI.Builder

.sentinel("sentinel1", 26379, "mymaster")

.withSentinel("sentinel2", 26379)

.withSentinel("sentinel3", 26379)

.withPassword("password".toCharArray())

.build();

RedisClient client = RedisClient.create(redisUri);

StatefulRedisConnection<String, String> connection = client.connect();

纯文本
---

## 五、Cluster 集成
java

RedisClusterClient clusterClient = RedisClusterClient.create(

RedisURI.create("redis://localhost:7000"));

StatefulRedisClusterConnection<String, String> conn = clusterClient.connect();

RedisAdvancedClusterCommands<String, String> commands = conn.sync();

commands.set("key", "value");  // 自动路由到正确的节点

纯文本
---

## 六、Lettuce vs Jedis

| 特性 | Lettuce | Jedis |
|------|---------|-------|
| 线程安全 | 是（单连接多线程） | 否（需连接池） |
| 异步/响应式 | 原生支持 | 需额外封装 |
| 性能 | 更高（Netty 事件驱动） | 较高 |
| Spring Boot 默认 | 是（2.x+） | 否 |
| 连接池 | 可选（Commons Pool2） | 必需（JedisPool） |
| 学习曲线 | 略陡 | 平缓 |

---

## 七、注意事项

1. **连接泄漏**：使用连接池时务必归还连接（try-with-resources）。
2. **事件循环组**：Lettuce 默认使用 Netty 的 EventLoopGroup，在应用关闭时需关闭 RedisClient。
3. **超时配置**：通过 `RedisURI.Builder.withTimeout(Duration)` 设置。

---

## 小结

- Lettuce 是高性能、线程安全的 Redis 客户端，支持同步/异步/响应式。
- Spring Boot 2.x 默认集成，推荐在新项目中使用。
- 支持 Sentinel、Cluster 等高级特性。