# Kafka Producer API 详解

## 一、Producer 核心配置

| 参数 | 说明 | 推荐值 |
|------|------|--------|
| `bootstrap.servers` | Broker 地址 | `host1:9092,host2:9092` |
| `key.serializer` | key 序列化器 | `StringSerializer` |
| `value.serializer` | value 序列化器 | `StringSerializer` 或 `JsonSerializer` |
| `acks` | 确认级别 | `all` |
| `retries` | 重试次数 | `3` |
| `batch.size` | 批次大小（字节） | `16384` |
| `linger.ms` | 等待时间（毫秒） | `5` |
| `buffer.memory` | 缓冲区总大小 | `33554432` |
| `compression.type` | 压缩类型 | `snappy` 或 `gzip` |
| `max.request.size` | 单次请求最大字节 | `1048576`（1MB） |

---

## 二、发送方式

### 1. 发后即忘（Fire-and-forget）

java

producer.send(new ProducerRecord<>("topic", "value"));

- 不关心结果，性能最高，但可能丢消息。

### 2. 同步发送

java

Future<RecordMetadata> future = producer.send(new ProducerRecord<>("topic", "value"));

RecordMetadata metadata = future.get(); // 阻塞直到返回

- 保证发送成功，但性能低。

### 3. 异步发送 + 回调（推荐）

java

producer.send(new ProducerRecord<>("topic", "value"), (metadata, exception) -> {

if (exception != null) {

// 处理失败

} else {

// 成功

}

});

- 兼顾性能和可靠性。

---

## 三、分区器

### 默认分区器
- 如果 key 不为 null，对 key 哈希取模（`Utils.toPositive(Utils.murmur2(keyBytes)) % numPartitions`）。
- 如果 key 为 null，使用轮询（RoundRobin）或粘性（Sticky）分区。

### 自定义分区器

java

public class CustomPartitioner implements Partitioner {

@Override

public int partition(String topic, Object key, byte[] keyBytes,

Object value, byte[] valueBytes, Cluster cluster) {

// 自定义逻辑

return Math.abs(key.hashCode()) % cluster.partitionCountForTopic(topic);

}

@Override

public void close() {}

@Override

public void configure(Map<String, ?> configs) {}

}

配置：

properties

partitioner.class=com.example.CustomPartitioner

---

## 四、幂等性与事务

### 开启幂等性

properties

enable.idempotence=true

- 自动设置 `acks=all` 和 `retries=Integer.MAX_VALUE`。
- 保证消息不重复（Exactly-Once 语义的一部分）。

### 事务

java

producer.initTransactions();

try {

producer.beginTransaction();

producer.send(new ProducerRecord<>("topic", "value1"));

producer.send(new ProducerRecord<>("topic", "value2"));

producer.commitTransaction();

} catch (Exception e) {

producer.abortTransaction();

}

---

## 五、性能调优

- **增大 batch.size**：减少网络请求次数。
- **启用压缩**：`compression.type=snappy` 或 `gzip`。
- **调整 linger.ms**：适当等待凑 batch。
- **使用异步发送**：避免阻塞。
- **调整 buffer.memory**：避免缓冲区满阻塞。

---

## 小结

- 异步发送 + 回调是最常用的方式。
- 幂等性是生产环境的推荐配置。
- 根据业务需求选择分区器。