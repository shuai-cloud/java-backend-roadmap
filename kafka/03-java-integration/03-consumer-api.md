# Kafka Consumer API 详解

## 一、Consumer 核心配置

| 参数 | 说明 | 推荐值 |
|------|------|--------|
| `bootstrap.servers` | Broker 地址 | `host1:9092,host2:9092` |
| `group.id` | 消费者组 ID | 必填 |
| `key.deserializer` | key 反序列化器 | `StringDeserializer` |
| `value.deserializer` | value 反序列化器 | `StringDeserializer` 或 `JsonDeserializer` |
| `enable.auto.commit` | 是否自动提交 offset | `false` |
| `auto.offset.reset` | 无 offset 时从哪开始 | `earliest` 或 `latest` |
| `max.poll.records` | 单次 poll 最大条数 | `500` |
| `fetch.min.bytes` | 拉取最小字节数 | `1` |
| `fetch.max.wait.ms` | 拉取最大等待时间 | `500` |
| `max.poll.interval.ms` | 最大 poll 间隔 | `300000`（5分钟） |
| `session.timeout.ms` | 会话超时 | `45000` |

---

## 二、消费模式

### 1. 自动提交（不推荐生产）
java

props.put("enable.auto.commit", "true");

props.put("auto.commit.interval.ms", "1000");

- 可能重复消费或丢失消息。

### 2. 手动同步提交（推荐）
java

while (true) {

ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(1000));

for (ConsumerRecord<String, String> record : records) {

process(record);

}

consumer.commitSync(); // 处理完一批提交一次

}

### 3. 手动异步提交
java

consumer.commitAsync((offsets, exception) -> {

if (exception != null) {

log.error("提交失败", exception);

}

});

- 性能好，但可能重复（失败后不重试）。

### 4. 按分区提交
java

Map<TopicPartition, OffsetAndMetadata> offsets = new HashMap<>();

for (TopicPartition partition : records.partitions()) {

List<ConsumerRecord<String, String>> partitionRecords = records.records(partition);

for (ConsumerRecord<String, String> record : partitionRecords) {

process(record);

}

long lastOffset = partitionRecords.get(partitionRecords.size() - 1).offset();

offsets.put(partition, new OffsetAndMetadata(lastOffset + 1));

}

consumer.commitSync(offsets);

---

## 三、消费位置控制

### seek 到指定 offset
java

TopicPartition tp = new TopicPartition("test", 0);

consumer.assign(Arrays.asList(tp));

consumer.seek(tp, 100); // 从 offset 100 开始消费

### 获取当前 offset
java

long position = consumer.position(tp);

### 获取最早/最新 offset
java

Map<TopicPartition, Long> beginningOffsets = consumer.beginningOffsets(Arrays.asList(tp));

Map<TopicPartition, Long> endOffsets = consumer.endOffsets(Arrays.asList(tp));

---

## 四、多线程消费

### 方案1：每个分区一个线程
java

// 分配分区

consumer.assign(partitions);

for (TopicPartition partition : partitions) {

new Thread(() -> {

while (true) {

ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));

for (ConsumerRecord<String, String> record : records) {

process(record);

}

consumer.commitSync();

}

}).start();

}

- 注意：Consumer 不是线程安全的，每个线程需要独立的 Consumer 实例。

### 方案2：单线程 poll + 线程池处理
java

ExecutorService executor = Executors.newFixedThreadPool(10);

while (true) {

ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));

for (ConsumerRecord<String, String> record : records) {

executor.submit(() -> process(record));

}

consumer.commitSync();

}

- 需要保证处理顺序（如按分区顺序提交 offset）。

---

## 五、优雅关闭
java

Runtime.getRuntime().addShutdownHook(new Thread(() -> {

consumer.wakeup(); // 唤醒 poll

try {

consumer.close();

} catch (Exception e) {

// ignore

}

}));

---

## 小结

- 手动提交 offset 是生产推荐方式。
- 控制消费位置（seek）用于重播或跳过。
- 多线程消费需注意线程安全和顺序。