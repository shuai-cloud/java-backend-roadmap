# Redis Pipeline（管道）

Pipeline 是一种**批量执行命令**的机制，可以将多个命令一次性发送到 Redis 服务器，然后一次性读取所有响应。它显著减少了网络往返时间（RTT）。

---

## 一、为什么需要 Pipeline？

在没有 Pipeline 的情况下，执行 N 条命令需要 N 次网络往返（请求→响应→请求→响应...）。Pipeline 将这些命令打包成一次请求发送，服务器处理完后一次性返回所有响应。

**对比示意图：**
无 Pipeline：

Client:  [CMD1]  ---->  Server

Server:          [RESP1] ----> Client

Client:  [CMD2]  ---->  Server

Server:          [RESP2] ----> Client

... 总共 N 次往返

有 Pipeline：

Client:  [CMD1][CMD2]...[CMDN]  ---->  Server

Server:  [RESP1][RESP2]...[RESPN]  ----> Client

总共 1 次往返

---

## 二、Pipeline 的使用

### 命令行示例
bash

使用 --pipe 模式
echo -e '3\r\n$3\r\nSET\r\n$3\r\nkey\r\n$5\r\nvalue\r\n3\r\n$3\r\nGET\r\n$3\r\nkey\r\n' | redis-cli --pipe

### Java 示例（Jedis）
java

Jedis jedis = new Jedis("localhost", 6379);

Pipeline pipeline = jedis.pipelined();

// 批量添加命令

pipeline.set("key1", "val1");

pipeline.set("key2", "val2");

pipeline.incr("counter");

pipeline.get("key1");

// 同步发送并获取所有响应

List<Object> responses = pipeline.syncAndReturnAll();

// responses 顺序与命令顺序一致

### Java 示例（Lettuce）
java

RedisCommands<String, String> sync = connection.sync();

sync.setAutoFlushCommands(false);  // 手动控制刷新

List<RedisFuture<?>> futures = new ArrayList<>();

futures.add(sync.setAsync("k1", "v1"));

futures.add(sync.setAsync("k2", "v2"));

futures.add(sync.getAsync("k1"));

connection.flushCommands();  // 一次性发送

// 等待所有结果

LettuceFutures.awaitAll(5, TimeUnit.SECONDS, futures.toArray(new RedisFuture[0]));

---

## 三、Pipeline 的注意事项

1. **非原子性**：Pipeline 只是批量发送，但命令之间没有事务隔离。如果需要在 Pipeline 中保证原子性，应使用 Lua 脚本或事务。
2. **内存占用**：Pipeline 会将所有命令的响应保存在客户端内存中，直到 `sync()` 调用。如果命令太多，可能导致内存溢出。建议分批发送（例如每 1000 条一批）。
3. **与事务的区别**：
    - Pipeline：批量发送，但命令可能被其他客户端的命令穿插执行。
    - MULTI/EXEC：保证原子执行，但会阻塞其他命令。
4. **适用场景**：大量独立命令的批量操作（如批量写入、批量读取）。

---

## 四、性能对比

| 命令数 | 无 Pipeline | 有 Pipeline | 提升倍数 |
|--------|------------|-------------|----------|
| 10     | ~5ms       | ~1ms        | 5x       |
| 100    | ~50ms      | ~3ms        | 16x      |
| 1000   | ~500ms     | ~20ms       | 25x      |

（数据基于本地网络，实际提升取决于网络延迟）

---

## 五、应用场景

### 1. 批量写入缓存
java

Pipeline p = jedis.pipelined();

for (User user : userList) {

p.set("user:" + user.getId(), JsonUtil.toJson(user));

}

p.sync();

### 2. 批量读取
java

Pipeline p = jedis.pipelined();

for (Long id : ids) {

p.get("user:" + id);

}

List<Object> results = p.syncAndReturnAll();

### 3. 批量计数器
java

Pipeline p = jedis.pipelined();

for (String articleId : articleIds) {

p.incr("article:views:" + articleId);

}

p.sync();

---

## 六、Pipeline 的限制

- 不能保证原子性（需要结合事务或 Lua）。
- 如果命令之间存在依赖关系（后一条命令依赖前一条的结果），Pipeline 无法处理。
- 长时间运行的 Pipeline 可能占用服务器资源。

---

## 小结

- Pipeline 通过批量发送命令大幅减少网络延迟。
- 适用于无依赖关系的批量操作。
- 注意内存管理和非原子性特性。
- 与 Lua 脚本搭配使用可以兼顾性能和原子性。