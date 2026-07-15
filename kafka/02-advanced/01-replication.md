# Kafka 副本机制与 ISR

## 一、为什么需要副本？

Kafka 通过副本（Replica）实现高可用。每个分区有多个副本，分布在不同的 Broker 上。副本分为 Leader 和 Follower。

- **Leader**：负责处理读写请求。
- **Follower**：从 Leader 同步数据，当 Leader 宕机时选举为新 Leader。

## 二、ISR（In-Sync Replicas）

### 定义
ISR 是与 Leader 保持同步的副本集合。只有 ISR 中的副本才有资格被选举为 Leader。

### 同步条件
Follower 需要定期向 Leader 发送 fetch 请求，拉取最新消息。如果 Follower 落后太多（超过 `replica.lag.time.max.ms`，默认 30 秒），就会被踢出 ISR。

### 为什么不用所有副本？
- 如果 Follower 落后太多，让它当 Leader 会导致数据丢失。
- ISR 机制在可用性和一致性之间取得平衡。

### unclean.leader.election
- `unclean.leader.election.enable=false`（默认）：只允许 ISR 中的副本成为 Leader，保证数据一致性，但可能降低可用性。
- `true`：允许非 ISR 副本成为 Leader，可用性优先，但可能丢数据。

---

## 三、副本系数（replication.factor）

- 生产环境建议设为 2 或 3。
- 副本数越多，可靠性越高，但也会增加存储和网络开销。
- 副本数不能超过 Broker 数量。

---

## 四、Leader 选举

1. 当 Leader 宕机时，Controller（Kafka 集群中的一个 Broker）负责选举新 Leader。
2. 从 ISR 中选出第一个副本作为新 Leader。
3. 如果 ISR 为空且 `unclean.leader.election.enable=true`，则从所有副本中选举。

---

## 五、数据一致性

- **acks=all**：生产者等待所有 ISR 副本确认，保证消息不丢失。
- **min.insync.replicas**：指定最少同步副本数，配合 acks=all 使用。例如设为 2，则至少 2 个副本确认才返回成功。

---

## 小结

- 副本机制是 Kafka 高可用的基础。
- ISR 是动态维护的同步副本集合，平衡一致性和可用性。
- 生产建议：`replication.factor=3`，`min.insync.replicas=2`，`acks=all`。