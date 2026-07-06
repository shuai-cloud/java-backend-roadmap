# 消息队列

Redis 可以作为轻量级消息队列使用，支持 List、Pub/Sub、Stream 三种方式。

---

## 一、基于 List 的消息队列

### 原理

- 生产者使用 `LPUSH` 将消息推入 List。
- 消费者使用 `BRPOP` 阻塞式弹出消息。

### 生产者
java

public void sendMessage(String queue, String message) {

redisTemplate.opsForList().leftPush(queue, message);

}

### 消费者（独立线程）
java

@Component

public class MessageConsumer {

@PostConstruct

public void start() {

new Thread(() -> {

while (true) {

try {

// 阻塞 5 秒等待消息

String message = redisTemplate.opsForList()

.rightPop("task:queue", 5, TimeUnit.SECONDS);

if (message != null) {

handleMessage(message);

}

} catch (Exception e) {

log.error("消费消息失败", e);

}

}

}).start();

}

private void handleMessage(String message) {
// 处理消息
}
}

### 优点
- 实现简单。
- 支持阻塞读取。

### 缺点
- 消息不持久化（Redis 重启丢失）。
- 不支持消费者组（多个消费者竞争消费）。
- 无法回溯历史消息。

---

## 二、基于 Pub/Sub 的消息队列

### 原理

- 生产者向频道发布消息。
- 消费者订阅频道，接收消息。

### 生产者
java

public void publish(String channel, String message) {

redisTemplate.convertAndSend(channel, message);

}

### 消费者
java

@Component

public class MessageListener extends JedisPubSub {

@Override

public void onMessage(String channel, String message) {

System.out.println("收到消息: " + message);

}

}

// 配置监听

@Bean

public MessageListenerAdapter listenerAdapter() {

return new MessageListenerAdapter(new RedisMessageListener());

}

@Bean

public RedisMessageListenerContainer container(RedisConnectionFactory factory) {

RedisMessageListenerContainer container = new RedisMessageListenerContainer();

container.setConnectionFactory(factory);

container.addMessageListener(listenerAdapter(), new PatternTopic("orders:*"));

return container;

}

### 优点
- 实时性高。
- 支持广播（1:N）。

### 缺点
- 消息不持久化，消费者离线丢失消息。
- 不支持消息确认和重试。
- 缓冲区满会断开连接。

---

## 三、基于 Stream 的消息队列（推荐）

Redis 5.0 引入的 Stream 是功能最完善的消息队列方案。

### 生产者
java

public String sendMessage(String stream, Map<String, String> body) {

return redisTemplate.opsForStream()

.add(StreamRecords.newRecord()

.ofMap(body)

.withStreamKey(stream));

}

### 消费者组
java

// 创建消费者组（从最新消息开始消费）

redisTemplate.opsForStream().createGroup("orders", "order-group");

// 消费消息

List<MapRecord<String, String, String>> messages = redisTemplate.opsForStream()

.read(Consumer.from("order-group", "consumer-1"),

StreamReadOptions.empty().count(1).block(Duration.ofSeconds(5)),

StreamOffset.create("orders", ReadOffset.lastConsumed()));

for (MapRecord<String, String, String> msg : messages) {

// 处理消息

handle(msg.getValue());

// 确认消息

redisTemplate.opsForStream().acknowledge("orders", "order-group", msg.getId());

}

### 优点
- 消息持久化。
- 支持消费者组（负载均衡）。
- 支持消息确认（ACK）和重试。
- 支持消息回溯。

### 缺点
- 比 List 和 Pub/Sub 复杂。
- 性能不如专业消息队列（如 RabbitMQ、Kafka）。

---

## 四、在苍穹外卖中的应用

- **来单提醒**：使用 WebSocket 直接推送，也可以先用 Stream 存储消息，再由管理端消费。
- **催单**：用户端发送催单消息到 Stream，管理端消费后通过 WebSocket 提醒商家。
- **异步任务**：如订单超时取消、积分发放等，可以使用 Stream 作为任务队列。

---

## 五、消息队列选型建议

| 场景 | 推荐方案 |
|------|----------|
| 简单任务队列，允许丢失 | List |
| 实时广播通知 | Pub/Sub |
| 可靠消息传递，需要 ACK | Stream |
| 高吞吐、持久化、分布式 | RabbitMQ / Kafka |

---

## 小结

- Redis 的 List、Pub/Sub、Stream 可以满足不同级别的消息队列需求。
- Stream 是最推荐的方式，兼具持久化、消费者组、ACK 等特性。
- 对于生产环境的高要求场景，建议使用专业的消息队列中间件。