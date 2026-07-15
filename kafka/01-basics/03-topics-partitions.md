# Topic 与分区

## 一、Topic 是什么？

Topic 是消息的逻辑分类，类似数据库的表。生产者将消息发到 Topic，消费者从 Topic 拉取消息。一个 Topic 可以有多个分区。

## 二、分区（Partition）

### 为什么需要分区？
- **并行度**：多个消费者可以同时消费不同分区，提升吞吐。
- **水平扩展**：分区可以分布在不同 Broker 上，突破单机限制。
- **顺序性**：分区内消息有序，全局无序。

### 分区数设置
- 分区数越多，并行度越高，但也会增加文件句柄和 Rebalance 时间。
- 建议：分区数 ≤ Broker 数量 × 副本数（避免单机过热）。
- 经验值：根据预期的吞吐量估算，通常 3~10 个分区足够。

### 分区与消费者的关系
- 一个分区只能被同一个消费者组内的**一个**消费者消费。
- 消费者数 ≤ 分区数，否则有消费者闲置。
- 分区数可以增加，但不能减少（减少会丢失数据）。

---

## 三、分区策略

### 生产者分区策略
1. **指定分区**：`ProducerRecord` 中直接指定 partition。
2. **key 哈希**：对 key 的哈希值取模（`key.hashCode() % numPartitions`），相同 key 进入同一分区。
3. **轮询**：无 key 时轮询分配，均匀分布。
4. **自定义分区器**：实现 `Partitioner` 接口。

### 消费者分区分配策略
| 策略 | 说明 |
|------|------|
| Range | 按主题范围分配，可能导致分配不均 |
| RoundRobin | 轮询分配，较均匀 |
| Sticky | 粘性分配，减少 Rebalance 时的变动 |
| CooperativeSticky | 合作式粘性，支持增量 Rebalance |

---

## 四、分区与副本

每个分区可以有多个副本（replication-factor），副本分布在不同的 Broker 上。副本分为 Leader 和 Follower，读写都在 Leader，Follower 同步数据。Leader 宕机时从 ISR 中选举新 Leader。

---

## 五、命令行操作

bash

创建 Topic（指定分区数和副本数）

kafka-topics --create --topic my-topic --partitions 3 --replication-factor 2 --bootstrap-server localhost:9092

查看 Topic 详情

kafka-topics --describe --topic my-topic --bootstrap-server localhost:9092

修改分区数（只能增加）

kafka-topics --alter --topic my-topic --partitions 5 --bootstrap-server localhost:9092

删除 Topic

kafka-topics --delete --topic my-topic --bootstrap-server localhost:9092

## 小结

- 分区是 Kafka 并行和扩展的基础。
- 分区数设置需权衡并行度和开销。
- 生产者分区策略影响数据分布，消费者分配策略影响负载均衡。