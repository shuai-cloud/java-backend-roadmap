# 消息可靠性：acks、幂等性、事务

## 一、生产者可靠性

### acks 参数
| 值 | 说明 | 风险 |
|----|------|------|
| `0` | 不等待确认，只管发 | 可能丢消息 |
| `1` | 等待 Leader 确认 | Leader 宕机可能丢 |
| `all`（或 `-1`） | 等待所有 ISR 确认 | 最可靠，但延迟略高 |

### 重试机制
- `retries`：重试次数（默认 Integer.MAX_VALUE）。
- `retry.backoff.ms`：重试间隔（默认 100ms）。
- 重试可能导致消息重复，需要幂等性或去重。

### 幂等性（Idempotence）
- `enable.idempotence=true`：生产者开启幂等性。
- 原理：每个 Producer 有一个 PID，每条消息带序列号，Broker 去重。
- 保证消息不重复（Exactly-Once 语义的一部分）。

### 事务（Transactions）
- 实现跨分区原子写入。
- 需要设置 `transactional.id`，调用 `initTransactions()`、`beginTransaction()`、`commitTransaction()`。
- 适用于“要么都写，要么都不写”的场景。

---

## 二、消费者可靠性

### 手动提交 Offset
- 推荐手动提交，避免自动提交导致消息丢失。
- 处理完消息后再提交，保证 At-Least-Once 语义。
- 如果处理失败，不提交，下次重新消费（可能重复）。

### 幂等消费
- 消费者侧需要自己实现幂等（如通过唯一 ID 去重）。
- 因为 Kafka 不保证 Exactly-Once 消费（除非事务）。

### 死信队列
- 对于重试多次仍失败的消息，写入死信 Topic，人工处理。

---

## 三、Broker 可靠性

- 副本机制（replication.factor ≥ 2）。
- 配置 `min.insync.replicas` 防止 ISR 太少时写入。
- 定期备份 Kafka 数据目录。

---

## 四、总结：如何保证消息不丢失？

| 环节 | 措施 |
|------|------|
| 生产者 | acks=all，重试，幂等性 |
| Broker | 副本数≥2，min.insync.replicas≥2 |
| 消费者 | 手动提交，处理完再提交 |

---

## 小结

- 消息可靠性需要生产者、Broker、消费者三方配合。
- 幂等性解决重复问题，事务解决原子性问题。
- 生产环境建议开启幂等性，acks=all，手动提交 offset。