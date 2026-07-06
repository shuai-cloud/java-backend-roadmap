# Spring Data Redis 与 Spring Cache

Spring Data Redis 是 Spring 生态中对 Redis 操作的封装，提供了 `RedisTemplate` 和 `StringRedisTemplate`，并集成了 Spring Cache 抽象。

---

## 一、引入依赖
xml

<dependency>

<groupId>org.springframework.boot</groupId>

<artifactId>spring-boot-starter-data-redis</artifactId>

</dependency>

<dependency>

<groupId>org.apache.commons</groupId>

<artifactId>commons-pool2</artifactId>

</dependency>

纯文本
---

## 二、配置文件（application.yml）
yaml

spring:

data:

redis:

host: localhost

port: 6379

password: yourpassword

database: 0

timeout: 3000ms

lettuce:

pool:

max-active: 100

max-idle: 20

min-idle: 5

max-wait: 3000ms

纯文本
---

## 三、RedisTemplate 的使用

### 1. 注入
java

@Autowired

private RedisTemplate<String, Object> redisTemplate;

@Autowired

private StringRedisTemplate stringRedisTemplate;  // key/value 都是 String

纯文本
### 2. 操作字符串
java

stringRedisTemplate.opsForValue().set("name", "Alice");

String name = stringRedisTemplate.opsForValue().get("name");

纯文本
### 3. 操作哈希
java

redisTemplate.opsForHash().put("user:1001", "name", "Bob");

String name = (String) redisTemplate.opsForHash().get("user:1001", "name");

纯文本
### 4. 操作列表
java

redisTemplate.opsForList().leftPush("queue", "task1");

String task = (String) redisTemplate.opsForList().leftPop("queue");

纯文本
### 5. 设置过期时间
java

redisTemplate.expire("key", 60, TimeUnit.SECONDS);

纯文本
### 6. 使用 ValueOperations 简化
java

ValueOperations<String, String> ops = stringRedisTemplate.opsForValue();

ops.set("key", "value", 10, TimeUnit.MINUTES);  // 带过期时间

纯文本
---

## 四、序列化配置

默认使用 JDK 序列化，可读性差且占用空间大。建议配置 JSON 序列化：
java

@Configuration

public class RedisConfig {

@Bean

public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory factory) {

RedisTemplate<String, Object> template = new RedisTemplate<>();

template.setConnectionFactory(factory);

纯文本
// JSON 序列化
Jackson2JsonRedisSerializer<Object> jacksonSer = new Jackson2JsonRedisSerializer<>(Object.class);
ObjectMapper om = new ObjectMapper();
om.setVisibility(PropertyAccessor.ALL, JsonAutoDetect.Visibility.ANY);
om.activateDefaultTyping(LazyValidatorFactory.class, ObjectMapper.DefaultTyping.NON_FINAL);
jacksonSer.setObjectMapper(om);

// String 序列化（key）
StringRedisSerializer stringSer = new StringRedisSerializer();

template.setKeySerializer(stringSer);
template.setHashKeySerializer(stringSer);
template.setValueSerializer(jacksonSer);
template.setHashValueSerializer(jacksonSer);

template.afterPropertiesSet();
return template;
}
}

纯文本
---

## 五、Spring Cache 集成

### 1. 开启缓存
java

@EnableCaching

@SpringBootApplication

public class Application {}

纯文本
### 2. 使用缓存注解
java

@Service

public class ProductService {

@Cacheable(value = "products", key = "#id")   // 查询时缓存

public Product getById(Long id) {

// 从数据库查询

return productMapper.selectById(id);

}

纯文本
@CachePut(value = "products", key = "#product.id")  // 更新缓存
public Product update(Product product) {
productMapper.update(product);
return product;
}

@CacheEvict(value = "products", key = "#id")  // 删除缓存
public void delete(Long id) {
productMapper.deleteById(id);
}
}

纯文本
### 3. 配置缓存过期时间
yaml

spring:

cache:

type: redis

redis:

time-to-live: 3600000   # 全局过期时间（毫秒），1小时

cache-null-values: false  # 是否缓存 null

use-key-prefix: true

key-prefix: "cache:"

纯文本
或通过编程方式配置：
java

@Bean

public RedisCacheManager cacheManager(RedisConnectionFactory factory) {

RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()

.entryTtl(Duration.ofHours(1))

.serializeKeysWith(RedisSerializationContext.SerializationPair.fromSerializer(new StringRedisSerializer()))

.serializeValuesWith(RedisSerializationContext.SerializationPair.fromSerializer(new GenericJackson2JsonRedisSerializer()))

.disableCachingNullValues();

纯文本
return RedisCacheManager.builder(factory)
.cacheDefaults(config)
.withInitialCacheConfigurations(Map.of(
"products", RedisCacheConfiguration.defaultCacheConfig().entryTtl(Duration.ofMinutes(30)),
"users", RedisCacheConfiguration.defaultCacheConfig().entryTtl(Duration.ofHours(2))
))
.build();
}

纯文本
---

## 六、在苍穹外卖中的应用
java

// 缓存菜品分类

@Cacheable(value = "category", key = "#type")

public List<Category> getByType(Integer type) {

return categoryMapper.listByType(type);

}

// 缓存店铺营业状态

@Cacheable(value = "shopStatus", key = "'status'")

public Integer getShopStatus() {

return shopMapper.getStatus();

}

// 更新后清除缓存

@CacheEvict(value = "shopStatus", allEntries = true)

public void setShopStatus(Integer status) {

shopMapper.updateStatus(status);

}

纯文本
---

## 七、注意事项

1. **缓存穿透**：使用 `@Cacheable` 时，如果查询结果为 null，默认不会缓存。可配置 `cache-null-values: true` 并设置较短 TTL。
2. **缓存雪崩**：设置不同的 TTL，避免大量缓存同时过期。
3. **缓存击穿**：对热点数据使用互斥锁或永不过期策略。
4. **序列化**：确保缓存的对象实现了 Serializable 或配置了合适的序列化器。

---

## 小结

- Spring Data Redis 提供了 `RedisTemplate` 和 `StringRedisTemplate` 简化 Redis 操作。
- 结合 Spring Cache 注解（`@Cacheable`、`@CachePut`、`@CacheEvict`）可快速实现缓存功能。
- 合理配置序列化方式和过期时间是生产环境的关键。