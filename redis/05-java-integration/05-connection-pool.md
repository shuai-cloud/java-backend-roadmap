# Redis 连接池配置

连接池是 Redis 客户端的重要组件，它可以复用连接，避免频繁创建和销毁连接带来的性能开销。

---

## 一、为什么需要连接池？

- **减少开销**：创建 TCP 连接需要 3 次握手，销毁需要 4 次挥手，频繁操作会消耗大量时间和资源。
- **控制资源**：限制最大连接数，防止 Redis 服务器被过多连接压垮。
- **提高响应速度**：连接池中的连接立即可用，无需等待新连接建立。

---

## 二、连接池的核心参数

### 通用参数（适用于 JedisPool、Lettuce Pool、Redisson）

| 参数 | 说明 | 建议值 |
|------|------|--------|
| maxTotal / maxActive | 最大连接数 | 50~200（取决于并发量） |
| maxIdle | 最大空闲连接数 | 一般为 maxTotal 的一半 |
| minIdle | 最小空闲连接数 | 5~10 |
| maxWaitMillis | 获取连接的最大等待时间（ms） | 3000~5000 |
| testOnBorrow | 获取连接时是否测试可用性 | true（生产环境） |
| testOnReturn | 归还连接时是否测试 | false |
| testWhileIdle | 空闲时是否定期测试 | true |
| timeBetweenEvictionRunsMillis | 空闲连接回收间隔（ms） | 30000 |
| minEvictableIdleTimeMillis | 空闲连接存活时间（ms） | 60000 |

---

## 三、Jedis 连接池配置
java

JedisPoolConfig config = new JedisPoolConfig();

config.setMaxTotal(100);

config.setMaxIdle(20);

config.setMinIdle(5);

config.setMaxWaitMillis(3000);

config.setTestOnBorrow(true);

config.setTestOnReturn(false);

config.setTestWhileIdle(true);

config.setTimeBetweenEvictionRunsMillis(30000);

config.setMinEvictableIdleTimeMillis(60000);

JedisPool pool = new JedisPool(config, "localhost", 6379, 2000, "password");

纯文本
---

## 四、Lettuce 连接池配置

Lettuce 使用 Commons Pool2，配置方式类似：
java

GenericObjectPoolConfig<StatefulRedisConnection<String, String>> poolConfig = new GenericObjectPoolConfig<>();

poolConfig.setMaxTotal(100);

poolConfig.setMaxIdle(20);

poolConfig.setMinIdle(5);

poolConfig.setMaxWait(Duration.ofSeconds(3));

poolConfig.setTestOnBorrow(true);

poolConfig.setTestOnReturn(false);

poolConfig.setTestWhileIdle(true);

poolConfig.setTimeBetweenEvictionRuns(Duration.ofSeconds(30));

poolConfig.setMinEvictableIdleDuration(Duration.ofSeconds(60));

RedisClient client = RedisClient.create("redis://localhost:6379");

ObjectPool<StatefulRedisConnection<String, String>> pool = ConnectionPoolSupport

.createGenericObjectPool(() -> client.connect(), poolConfig);

纯文本
---

## 五、Redisson 连接池配置

Redisson 的配置在 `Config` 中：
java

Config config = new Config();

config.useSingleServer()

.setAddress("redis://localhost:6379")

.setPassword("password")

.setConnectionPoolSize(100)          // 相当于 maxTotal

.setConnectionMinimumIdleSize(10)    // 相当于 minIdle

.setConnectTimeout(5000)

.setTimeout(3000)

.setRetryAttempts(3)

.setRetryInterval(1500);

纯文本
---

## 六、Spring Boot 中的连接池配置

在 `application.yml` 中配置 Lettuce 连接池：
yaml

spring:

data:

redis:

host: localhost

port: 6379

password: yourpassword

lettuce:

pool:

max-active: 100

max-idle: 20

min-idle: 5

max-wait: 3000ms

time-between-eviction-runs: 30000ms

纯文本
---

## 七、连接池大小估算

连接池大小并非越大越好，过大会占用 Redis 资源，过小会导致请求排队。

**估算公式**：
连接数 ≈ (核心数 * 2) + 有效磁盘数

纯文本
或根据 QPS 估算：
连接数 = QPS / (1000ms / 平均响应时间)

纯文本
**示例**：平均响应时间 5ms，QPS 为 10000，则需要 `10000 / (1000/5) = 50` 个连接。

**建议**：
- 常规业务：50~100
- 高并发业务：100~200
- 避免超过 500（除非 Redis 配置了很高的 maxclients）

---

## 八、连接池监控

### 1. Jedis 监控
java

JedisPool pool = ...;

System.out.println("Active: " + pool.getNumActive());

System.out.println("Idle: " + pool.getNumIdle());

System.out.println("Waiters: " + pool.getNumWaiters());

纯文本
### 2. Lettuce 监控
java

ObjectPool<?> pool = ...;

System.out.println("Borrowed: " + pool.getNumActive());

System.out.println("Idle: " + pool.getNumIdle());

纯文本
### 3. Actuator 端点（Spring Boot）
yaml

management:

endpoints:

web:

exposure:

include: health,info,metrics

纯文本
访问 `/actuator/health` 查看 Redis 健康状态。

---

## 九、常见问题

### Q1：连接池耗尽怎么办？
- 检查 `maxActive` 是否过小。
- 检查是否有连接泄漏（未归还）。
- 检查 Redis 响应是否过慢导致连接被长时间占用。

### Q2：连接池空闲连接过多怎么办？
- 适当降低 `minIdle`。
- 设置 `timeBetweenEvictionRunsMillis` 定期回收空闲连接。

### Q3：连接池中连接全部失效？
- 网络闪断或 Redis 重启可能导致连接池中的连接全部失效。
- 设置 `testOnBorrow=true` 可以在获取连接时自动剔除无效连接。

---

## 小结

- 连接池是 Redis 客户端的基础设施，必须合理配置。
- 核心参数：maxTotal、maxIdle、minIdle、maxWaitMillis、testOnBorrow。
- 连接池大小应根据 QPS 和响应时间估算，不宜过大或过小。
- 监控连接池状态，及时发现连接泄漏或耗尽问题。