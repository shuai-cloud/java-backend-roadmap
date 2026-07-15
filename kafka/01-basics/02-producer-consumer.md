# Kafka 生产者与消费者基础

## 一、生产者（Producer）

### 发送流程
1. 创建 ProducerRecord（包含 Topic、分区（可选）、key、value）。
2. 序列化 key 和 value。
3. 分区器决定发到哪个分区（默认 key 哈希取模，无 key 则轮询）。
4. 消息进入缓冲区（batch），由 sender 线程批量发送。
5. Broker 返回响应（ack 级别决定）。

### 重要参数
| 参数 | 说明 | 建议值 |
|------|------|--------|
| `bootstrap.servers` | Broker 地址列表 | `localhost:9092` |
| `key.serializer` | key 序列化类 | `StringSerializer` |
| `value.serializer` | value 序列化类 | `StringSerializer` |
| `acks` | 确认级别 | `all`（最可靠） |
| `retries` | 重试次数 | `3` |
| `batch.size` | 批次大小（字节） | `16384`（16KB） |
| `linger.ms` | 等待时间（毫秒） | `5`（凑够 batch 或超时发送） |
| `buffer.memory` | 缓冲区总大小 | `33554432`（32MB） |

### Java 示例

java

Properties props = new Properties();

props.put("bootstrap.servers", "localhost:9092");

props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");

props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");

props.put("acks", "all");

Producer<String, String> producer = new KafkaProducer<>(props);

producer.send(new ProducerRecord<>("test", "key1", "value1"));

producer.close();

### 异步发送带回调

java

producer.send(new ProducerRecord<>("test", "key", "value"), (metadata, exception) -> {

if (exception != null) {

log.error("发送失败", exception);

} else {

log.info("发送成功，分区：{}，偏移量：{}", metadata.partition(), metadata.offset());

}

});

---

## 二、消费者（Consumer）

### 消费流程
1. 订阅 Topic。
2. 加入消费者组，触发 Rebalance，分配分区。
3. 轮询拉取消息（poll）。
4. 处理消息。
5. 提交 Offset。

### 重要参数
| 参数 | 说明 | 建议值 |
|------|------|--------|
| `bootstrap.servers` | Broker 地址 | `localhost:9092` |
| `group.id` | 消费者组 ID | 必填 |
| `key.deserializer` | key 反序列化类 | `StringDeserializer` |
| `value.deserializer` | value 反序列化类 | `StringDeserializer` |
| `enable.auto.commit` | 是否自动提交 offset | `false`（手动提交更可控） |
| `auto.offset.reset` | 无 offset 时从哪开始 | `earliest`（从头）或 `latest`（最新） |
| `max.poll.records` | 单次 poll 最大条数 | `500` |

### Java 示例

java

Properties props = new Properties();

props.put("bootstrap.servers", "localhost:9092");

props.put("group.id", "my-group");

props.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");

props.put("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");

props.put("enable.auto.commit", "false");

Consumer<String, String> consumer = new KafkaConsumer<>(props);

consumer.subscribe(Arrays.asList("test"));

while (true) {

ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(1000));

for (ConsumerRecord<String, String> record : records) {

System.out.printf("offset=%d, key=%s, value=%s%n", record.offset(), record.key(), record.value());

}

consumer.commitSync(); // 手动提交

}

### 提交 Offset 的方式
- **自动提交**（`enable.auto.commit=true`）：每隔 `auto.commit.interval.ms` 提交一次，可能重复消费。
- **手动同步提交**（`commitSync()`）：阻塞直到提交成功，保证不丢。
- **手动异步提交**（`commitAsync()`）：不阻塞，可配回调，可能重复。

---

## 小结

- 生产者关键参数：acks、retries、batch.size。
- 消费者关键参数：group.id、auto.offset.reset、手动提交。
- 生产环境推荐手动提交 offset，配合重试和死信队列。