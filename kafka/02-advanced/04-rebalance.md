# 再均衡（Rebalance）机制

## 一、什么是 Rebalance？

Rebalance 是消费者组内重新分配分区的过程。当消费者加入、离开或 Topic 分区数变化时触发。

## 二、Rebalance 的触发条件

1. 消费者加入组（新实例启动）。
2. 消费者离开组（关闭或超时）。
3. 消费者主动取消订阅。
4. Topic 分区数变化。
5. 消费者组订阅的 Topic 列表变化。

## 三、Rebalance 的过程

### 旧版（Eager Rebalance）
1. 所有消费者停止消费，撤销所有分区。
2. 消费者组协调器（Group Coordinator）重新分配分区。
3. 消费者重新分配分区，开始消费。
- 缺点：Stop-the-world，所有消费者暂停，影响较大。

### 新版（Sticky / Cooperative Rebalance）
- Sticky：尽量保持现有分配，只调整变化的部分。
- Cooperative：分阶段调整，消费者可以继续消费未受影响的分区。
- 优点：减少暂停时间，提升可用性。

---

## 四、如何减少 Rebalance 的影响？

### 1. 合理配置超时参数

properties

session.timeout.ms = 45000      # 会话超时（默认 45 秒）

heartbeat.interval.ms = 5000    # 心跳间隔（默认 3 秒）

max.poll.interval.ms = 300000   # 最大 poll 间隔（默认 5 分钟）

- 如果消费者处理时间较长，调大 `max.poll.interval.ms`，避免被误认为死亡。

### 2. 使用静态消费组
- 设置 `group.instance.id`，消费者重启时保留分区分配，不触发 Rebalance。
- 适用于有状态消费者（如需要本地缓存）。

### 3. 避免频繁加入/离开
- 确保消费者实例稳定，不要频繁重启。

### 4. 监控 Rebalance 事件
- 通过 JMX 指标或日志监控 Rebalance 次数和时长。

---

## 五、Rebalance 期间的消息处理

- Rebalance 发生时，未提交的 offset 会丢失，可能导致重复消费。
- 建议在 Rebalance 监听器中手动提交 offset 或保存状态。

java

consumer.subscribe(Arrays.asList("topic"), new ConsumerRebalanceListener() {

@Override

public void onPartitionsRevoked(Collection<TopicPartition> partitions) {

// 提交 offset

consumer.commitSync();

}

@Override
public void onPartitionsAssigned(Collection<TopicPartition> partitions) {
// 恢复状态
}

});

---

## 小结

- Rebalance 是消费者组的正常机制，但频繁触发会影响性能。
- 通过合理配置超时、使用静态消费组、监听 Rebalance 事件来优化。
- 新版 Sticky/Cooperative Rebalance 比旧版更友好。