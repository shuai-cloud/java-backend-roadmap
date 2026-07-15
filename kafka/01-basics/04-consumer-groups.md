# 消费者组与 Offset

## 一、消费者组（Consumer Group）

### 概念
- 一组消费者共同消费一个或多个 Topic。
- 每条消息只会被组内的**一个**消费者消费（点对点模式）。
- 不同消费者组可以独立消费同一条消息（发布-订阅模式）。

### 组内分区分配
- 每个分区只能分配给组内的一个消费者。
- 消费者数 ≤ 分区数，否则有消费者闲置。
- 当消费者加入或离开时，触发 Rebalance，重新分配分区。

---

## 二、Offset（偏移量）

### 作用
- 标识消费者在分区中的消费位置。
- 每条消息在分区内有一个唯一的 offset。
- 消费者提交 offset 后，下次从该位置继续消费。

### 提交方式
1. **自动提交**：`enable.auto.commit=true`，每隔 `auto.commit.interval.ms` 提交。可能重复消费（如处理完未提交就崩溃）。
2. **手动同步提交**：`commitSync()`，阻塞直到提交成功，保证不丢但可能重复（处理完提交前崩溃）。
3. **手动异步提交**：`commitAsync()`，不阻塞，可配回调，适合高吞吐。

### Offset 存储
- 旧版存在 ZooKeeper，新版存在 Kafka 内部 Topic `__consumer_offsets`（默认 50 个分区）。
- 可以通过 `kafka-consumer-groups` 命令查看。

---

## 三、命令行查看消费者组

bash

列出所有消费者组

kafka-consumer-groups --list --bootstrap-server localhost:9092

查看组详情（包括每个分区的 offset、lag）

kafka-consumer-groups --describe --group my-group --bootstrap-server localhost:9092

### Lag 是什么？
- Lag = 最新消息的 offset - 当前消费的 offset。
- Lag 越大，说明消费者落后越多，可能消费能力不足。

---

## 四、重置 Offset

bash

重置到最早

kafka-consumer-groups --reset-offsets --group my-group --topic test --to-earliest --execute --bootstrap-server localhost:9092

重置到指定时间

kafka-consumer-groups --reset-offsets --group my-group --topic test --to-datetime 2025-01-01T00:00:00.000 --execute --bootstrap-server localhost:9092

---

## 五、再均衡（Rebalance）

### 触发条件
- 消费者加入或离开组。
- 分区数发生变化。
- 订阅的 Topic 发生变化。

### 影响
- Rebalance 期间，消费者停止消费，可能导致短暂不可用。
- 旧版 Rebalance 是 Stop-the-world 的，新版（Sticky/Cooperative）支持增量调整。

### 如何减少 Rebalance 影响
- 设置合理的 `session.timeout.ms` 和 `heartbeat.interval.ms`。
- 使用静态消费组（`group.instance.id`）避免频繁 Rebalance。
- 避免消费者处理时间过长导致心跳超时。

- 消费者组实现点对点和发布-订阅。
- Offset 管理是消费可靠性的关键，推荐手动提交。
- Rebalance 是正常机制，但要避免频繁触发。