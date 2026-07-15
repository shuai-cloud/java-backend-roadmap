# 削峰填谷场景

在秒杀、大促等场景，瞬时流量远超系统处理能力，Kafka 作为缓冲层可以平滑流量。

---

## 一、场景：秒杀下单
用户请求 → 网关 → Kafka（seckill.orders）

↓

订单消费者（限速处理）

↓

数据库

- 用户请求直接写入 Kafka，快速返回“已接收”。
- 订单消费者以可控速度从 Kafka 拉取订单，写入数据库。
- 即使瞬间有百万请求，Kafka 也能承受，数据库不会被打爆。

---

## 二、实现

### 生产者（网关）
java

public String seckill(Long userId, Long productId) {

// 快速校验（如用户是否登录）

// 写入 Kafka

SeckillOrder order = new SeckillOrder(userId, productId);

kafkaTemplate.send("seckill.orders", userId.toString(), order);

return "排队中，请稍后查看结果";

}

### 消费者（限速处理）
java

@Component

public class SeckillConsumer {

@KafkaListener(topics = "seckill.orders", groupId = "seckill-group",

containerFactory = "batchFactory")

public void processOrders(List<SeckillOrder> orders, Acknowledgment ack) {

// 批量处理，限制每次处理 100 条

for (SeckillOrder order : orders) {

try {

orderService.processSeckill(order);

} catch (Exception e) {

// 记录失败，后续补偿

failedOrderService.save(order);

}

}

ack.acknowledge();

}

}

---

## 三、优势

- **保护数据库**：避免瞬间高并发写入。
- **用户体验好**：请求快速响应，不阻塞。
- **可扩展**：增加分区和消费者提升处理能力。

---

## 四、注意事项

- 需要前端轮询或 WebSocket 通知用户最终结果。
- 设置合理的消费速率，避免消费者压力过大。
- 监控队列长度和消费延迟。
