# Kafka 面试题精选
> 以下题目覆盖 Kafka 核心原理、实战经验和常见坑点。每个问题给出了“面试官想听什么”和“回答要点”。

---

## 一、基础概念

### 1. Kafka 是什么？核心组件有哪些？
**回答要点**：分布式流平台，核心组件包括 Broker、Topic、Partition、Producer、Consumer、Consumer Group、Offset、ZooKeeper/KRaft。

### 2. Kafka 为什么快？
**回答要点**：
- 顺序写磁盘（顺序 I/O 比随机 I/O 快很多）。
- 零拷贝（`sendfile` 系统调用，减少数据拷贝）。
- 批量处理（生产者批量发送，消费者批量拉取）。
- 分区并行（多个分区可被不同消费者并行消费）。
- 页缓存（利用操作系统 Page Cache）。

### 3. 什么是 Partition？为什么需要分区？
**回答要点**：分区是 Kafka 并行和扩展的基础。每个分区是一个有序的日志文件。分区数决定了最大并行度（消费者数 ≤ 分区数）。分区可以分布在多个 Broker 上，实现水平扩展。

### 4. 什么是 Consumer Group？有什么用？
**回答要点**：消费者组实现点对点模式（组内每条消息只被一个消费者消费）。不同消费者组可以独立消费同一条消息（发布订阅模式）。组内消费者数不能超过分区数，否则有闲置。

---

## 二、进阶原理

### 5. 如何保证消息不丢失？
**回答要点**：
- 生产者：`acks=all`，重试，开启幂等性。
- Broker：`replication.factor ≥ 2`，`min.insync.replicas ≥ 2`。
- 消费者：手动提交 offset，处理完再提交。

### 6. 如何保证消息顺序？
**回答要点**：分区内有序。如果需要全局有序，设分区数为 1。如果需要局部有序，按 key 分区（相同 key 进入同一分区）。注意重试可能破坏顺序，开启幂等性可解决。

### 7. 什么是 ISR？有什么作用？
**回答要点**：ISR 是与 Leader 保持同步的副本集合。只有 ISR 中的副本才有资格被选举为 Leader。ISR 机制在可用性和一致性之间取得平衡。如果 Follower 落后太多（超过 `replica.lag.time.max.ms`），会被踢出 ISR。

### 8. 什么是 Rebalance？如何减少影响？
**回答要点**：Rebalance 是消费者组内重新分配分区的过程。触发条件：消费者加入/离开、分区数变化等。减少影响的方法：
- 合理配置 `session.timeout.ms`、`max.poll.interval.ms`。
- 使用静态消费组（`group.instance.id`）。
- 监听 Rebalance 事件，在撤销分区前提交 offset。

### 9. Kafka 的幂等性和事务有什么区别？
**回答要点**：
- 幂等性（`enable.idempotence=true`）：保证生产者单会话内消息不重复，解决重试导致的重复。
- 事务（`transactional.id`）：保证跨分区原子写入，实现 Exactly-Once 语义。事务包含幂等性。

### 10. Kafka 的控制器（Controller）是什么？
**回答要点**：Controller 是 Kafka 集群中的一个 Broker，负责管理分区 Leader 选举、Topic 创建/删除、Broker 加入/离开等元数据操作。Controller 通过 ZooKeeper 选举产生。

---

## 三、实战与排错

### 11. 如何查看消费者 Lag？
**回答要点**：使用命令行 `kafka-consumer-groups --describe --group my-group --bootstrap-server localhost:9092`，查看 LAG 列。Lag 表示消费者落后最新消息的数量。Lag 过大说明消费能力不足或消费者挂掉。

### 12. 消息重复消费怎么办？
**回答要点**：原因可能是消费者处理完消息但未提交 offset 就崩溃，重启后重新消费。解决方案：
- 消费者侧实现幂等（如通过业务 ID 去重）。
- 使用数据库唯一索引或 Redis 记录已处理的消息 ID。
- 开启 Kafka 事务（但复杂）。

### 13. 消息积压怎么处理？
**回答要点**：
- 增加消费者（不超过分区数）。
- 增加分区数（需要重建 Topic 或使用新 Topic）。
- 优化消费者处理逻辑（批量处理、异步处理）。
- 临时提高消费速率（跳过不重要消息或降级）。

### 14. Kafka 集群扩容怎么做？
**回答要点**：
- 添加新 Broker，启动后自动加入集群。
- 使用 `kafka-reassign-partitions` 工具迁移分区到新 Broker。
- 可以手动指定分区分配计划，或自动生成。
- 迁移期间对业务有轻微影响（Leader 切换）。

### 15. Kafka 和 ZooKeeper 的关系是什么？
**回答要点**：早期 Kafka 依赖 ZooKeeper 存储元数据（Broker 列表、Topic 配置、Controller 选举等）。Kafka 2.8+ 引入 KRaft 模式，逐渐摆脱 ZooKeeper，但生产环境仍以 ZooKeeper 为主。KRaft 是未来的方向。

---

## 四、开放性问题

### 16. 你们公司为什么选择 Kafka（或其他 MQ）？
**回答要点**：结合业务场景说明。例如：
- “我们做日志收集，需要高吞吐，所以选 Kafka。”
- “我们做订单系统，需要可靠的消息确认和延迟消息，所以选 RabbitMQ。”
- “我们项目小，不想引入额外组件，用 Redis Stream 就够了。”

### 17. 如果让你设计一个消息队列，你会怎么设计？
**回答要点**：从存储、网络、分区、副本、消费者模型等角度回答。可以参考 Kafka 的设计思路：顺序写、零拷贝、分区、副本、ISR、消费者组等。

### 18. 谈谈你对 Kafka 的 Exactly-Once 语义的理解。
**回答要点**：Kafka 的 Exactly-Once 需要生产者幂等性 + 事务 + 消费者幂等消费。生产者事务保证跨分区原子写入，消费者需要自己实现幂等（如通过数据库唯一键）。实际生产中，大多数场景 At-Least-Once 就够用。

---

## 小结

- 面试 Kafka 时，不仅要背概念，更要理解设计思想和 trade-off。
- 结合实际项目经验（哪怕只是 demo）回答问题，会更有说服力。
- 准备好一个“你们公司用 Kafka 做什么”的故事，能串联起多个知识点。