# 异步解耦场景

Kafka 常用于微服务间的异步通信，实现服务解耦和削峰填谷。

---

## 一、场景：订单创建后发送通知

传统同步方式：
订单服务 → 短信服务 → 邮件服务 → App 推送

- 耦合度高，任一服务慢都会拖慢订单服务。
- 高峰期可能超时。

异步解耦后：
订单服务 → Kafka（order.created）

↓

┌──────────┼──────────┐

↓          ↓          ↓

短信服务    邮件服务    App推送

---

## 二、实现

### 订单服务（生产者）
java

@Service

public class OrderService {

@Autowired

private KafkaTemplate<String, OrderEvent> kafkaTemplate;

public void createOrder(Order order) {
// 保存订单到数据库
orderDao.save(order);
// 发送事件
OrderEvent event = new OrderEvent(order.getId(), order.getUserId(), "CREATED");
kafkaTemplate.send("order.created", order.getUserId().toString(), event);
}
}

### 短信服务（消费者）
java

@Component

public class SmsConsumer {

@KafkaListener(topics = "order.created", groupId = "sms-group")

public void sendSms(OrderEvent event) {

// 调用短信 API

smsService.send(event.getUserId(), "您的订单已创建");

}

}

---

## 三、优势

- **解耦**：订单服务不需要知道通知服务的细节。
- **削峰**：Kafka 缓冲瞬时高峰，下游按能力消费。
- **扩展性**：增加新的通知方式（如微信推送）只需新增消费者。

---

## 四、注意事项

- 确保消息可靠性（acks=all，手动提交）。
- 处理重复消息（幂等性）。
- 监控消费 lag，及时扩容消费者。