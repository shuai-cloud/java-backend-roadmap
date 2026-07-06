# 布隆过滤器

布隆过滤器（Bloom Filter）是一种空间效率极高的概率型数据结构，用于判断一个元素是否存在于集合中。它可能会误判（假阳性），但绝不会漏判（假阴性）。

---

## 一、布隆过滤器的原理

1. 初始化一个长度为 m 的位数组（bit array），所有位为 0。
2. 使用 k 个哈希函数，对每个元素计算 k 个哈希值，将对应位设为 1。
3. 查询时，同样计算 k 个哈希值，如果所有位都为 1，则元素可能存在；如果有任意一位为 0，则元素一定不存在。

---

## 二、布隆过滤器的特点

- **空间效率高**：相比 Set 或 HashMap，占用极少内存。
- **查询速度快**：O(k)，k 是哈希函数个数。
- **存在误判率**：可能把不存在的元素误判为存在（假阳性）。
- **无法删除元素**：标准布隆过滤器不支持删除（Counting Bloom Filter 可以）。
- **不支持遍历**：无法获取所有元素。

---

## 三、Redis 中的布隆过滤器

Redis 4.0+ 通过模块 `redisbloom` 提供了布隆过滤器支持。

### 安装模块

bash

方式1：编译安装

git clone https://github.com/RedisBloom/RedisBloom.git

cd RedisBloom

make

redis-server --loadmodule ./redisbloom.so

方式2：Docker

docker run -p 6379:6379 redislabs/rebloom

### 常用命令

bash

创建一个布隆过滤器，预期插入 1000 个元素，误判率 0.01

BF.RESERVE myfilter 0.01 1000

添加元素

BF.ADD myfilter "element1"

BF.ADD myfilter "element2"

批量添加

BF.MADD myfilter "elem1" "elem2" "elem3"

判断是否存在

BF.EXISTS myfilter "element1"   # 返回 1 或 0

批量判断

BF.MEXISTS myfilter "elem1" "elem2" "unknown"

---

## 四、Java 集成（Jedis + RedisBloom）

java

Jedis jedis = new Jedis("localhost", 6379);

// 创建过滤器

jedis.sendCommand(Protocol.Command.valueOf("BF.RESERVE"), "myfilter", "0.01", "1000");

// 添加

jedis.sendCommand(Protocol.Command.valueOf("BF.ADD"), "myfilter", "element1");

// 判断

Object result = jedis.sendCommand(Protocol.Command.valueOf("BF.EXISTS"), "myfilter", "element1");

System.out.println(result); // 1 或 0

如果 Redis 未安装 RedisBloom 模块，可以在 Java 中自行实现布隆过滤器（使用 Guava 或自定义）。

---

## 五、Java 本地布隆过滤器（Guava）

xml

<dependency>

<groupId>com.google.guava</groupId>

<artifactId>guava</artifactId>

<version>33.0.0-jre</version>

</dependency>


java

// 预期插入 10000 个元素，误判率 0.01

BloomFilter<String> bloomFilter = BloomFilter.create(

Funnels.stringFunnel(Charsets.UTF_8), 10000, 0.01);

// 添加

bloomFilter.put("element1");

bloomFilter.put("element2");

// 判断

boolean mightExist = bloomFilter.mightContain("element1"); // true

boolean definitelyNot = bloomFilter.mightContain("unknown"); // false（大概率）

---

## 六、应用场景

### 1. 缓存穿透防护

在查询数据库前，先检查布隆过滤器。如果 key 不存在，直接返回，避免查询数据库。

java

public Object getProduct(Long id) {

String key = "product:" + id;

// 布隆过滤器判断

if (!bloomFilter.mightContain(key)) {

return null; // 肯定不存在

}

// 查缓存

Object cached = redisTemplate.opsForValue().get(key);

if (cached != null) {

return cached;

}

// 查数据库

Object db = productMapper.selectById(id);

if (db != null) {

redisTemplate.opsForValue().set(key, db, 3600, TimeUnit.SECONDS);

}

return db;

}

### 2. 防止重复提交

在用户提交表单时，将请求的唯一标识（如 token）加入布隆过滤器，后续相同请求直接拒绝。

### 3. 爬虫 URL 去重

爬虫抓取网页时，使用布隆过滤器记录已访问的 URL，避免重复抓取。

### 4. 垃圾邮件过滤

将已知垃圾邮件的特征加入布隆过滤器，快速过滤。

---

## 七、注意事项

1. **误判率**：根据业务容忍度设置，通常 1%~5%。
2. **容量规划**：预估最大元素数量，过大浪费空间，过小导致误判率升高。
3. **无法删除**：如果需要删除，考虑 Counting Bloom Filter 或 Cuckoo Filter。
4. **数据初始化**：项目启动时，需要将已有的数据加载到布隆过滤器中。

---

## 八、在苍穹外卖中的应用

- **缓存穿透防护**：在查询菜品、套餐等热点数据时，先用布隆过滤器判断 ID 是否存在。
- **防止重复下单**：将已处理的订单 ID 加入布隆过滤器，快速判断是否重复。

---

## 小结

- 布隆过滤器是解决缓存穿透的有效手段。
- Redis 通过 RedisBloom 模块原生支持，也可以在 Java 中使用 Guava 实现。
- 注意误判率和容量规划，无法删除元素。