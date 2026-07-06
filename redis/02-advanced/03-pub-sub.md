# Redis 发布订阅（Pub/Sub）

Redis 的发布订阅是一种**消息通信模式**：发送者（Publisher）将消息发送到频道（Channel），订阅者（Subscriber）可以订阅一个或多个频道来接收消息。

---

## 一、核心概念

- **频道（Channel）**：消息的分类标识，类似主题（Topic）。
- **发布者（Publisher）**：向指定频道发送消息的客户端。
- **订阅者（Subscriber）**：订阅一个或多个频道，接收消息的客户端。
- **消息**：发布者发送的任意字符串。

---

## 二、常用命令

| 命令 | 作用 |
|------|------|
| `PUBLISH channel message` | 向频道发送消息 |
| `SUBSCRIBE channel [channel...]` | 订阅一个或多个频道 |
| `UNSUBSCRIBE [channel...]` | 退订频道 |
| `PSUBSCRIBE pattern [pattern...]` | 订阅匹配模式的频道（如 `news.*`） |
| `PUNSUBSCRIBE [pattern...]` | 退订模式匹配的频道 |
| `PUBSUB CHANNELS [pattern]` | 查看当前活跃的频道 |
| `PUBSUB NUMSUB channel [channel...]` | 查看频道的订阅者数量 |
| `PUBSUB NUMPAT` | 查看模式订阅的数量 |

---

## 三、基本使用示例

### 终端1：订阅频道
bash

127.0.0.1:6379> SUBSCRIBE news sports

Reading messages... (press Ctrl-C to quit)

"subscribe"

"news"

(integer) 1

"subscribe"

"sports"

(integer) 2

### 终端2：发布消息
bash

127.0.0.1:6379> PUBLISH news "Hello World!"

(integer) 1

127.0.0.1:6379> PUBLISH sports "Game over"

(integer) 1

### 终端1收到消息
"message"

"news"

"Hello World!"

"message"

"sports"

"Game over"

### 模式订阅示例
bash

订阅所有以 "news." 开头的频道
PSUBSCRIBE news.*

发布到 news.china 或 news.world 都能收到
PUBLISH news.china "China news"

---

## 四、Pub/Sub 的特点

- **即发即弃**：消息不会持久化，如果订阅者不在线，消息就会丢失。
- **广播模式**：所有订阅者都会收到消息（1:N）。
- **不支持消息堆积**：如果订阅者消费速度慢，消息会在 Redis 缓冲区累积，超过 `client-output-buffer-limit pubsub` 限制后会被断开连接。
- **轻量级**：适合实时通知场景，不适合可靠的消息传递。

---

## 五、应用场景

### 1. 实时聊天
用户订阅 `chat:room1`，其他人发布消息到该频道，所有在线用户即时收到。

### 2. 系统通知
后台管理员发布系统公告到 `notice` 频道，所有在线用户接收。

### 3. 配置动态刷新
微服务订阅 `config:refresh`，当配置变更时发布消息，服务端监听到后重新加载配置。

### 4. 苍穹外卖中的使用
虽然苍穹外卖使用的是 WebSocket，但也可以用 Pub/Sub 实现来单提醒：订单服务发布消息到 `order:new`，管理端订阅后弹出提醒。

---

## 六、Pub/Sub vs 消息队列

| 对比维度 | Redis Pub/Sub | 专业消息队列（RabbitMQ/Kafka） |
|----------|---------------|-------------------------------|
| 消息持久化 | 否 | 是 |
| 消息可靠性 | 低（丢失不重试） | 高（ACK 机制） |
| 消费模式 | 广播（所有订阅者） | 点对点/广播/分组 |
| 消息堆积 | 不支持（超出 buffer 断开） | 支持海量堆积 |
| 顺序保证 | 单频道有序 | 分区内有序 |
| 复杂度 | 极低 | 较高 |

**结论**：Pub/Sub 适用于实时性要求高、允许少量丢失的场景；如果需要可靠消息传递，应使用专业的消息队列。

---

## 七、Java 集成示例（Jedis）
java

// 发布者

Jedis jedis = new Jedis("localhost", 6379);

jedis.publish("news", "Hello from Java");

// 订阅者（需要单独线程）

Jedis subscriberJedis = new Jedis("localhost", 6379);

subscriberJedis.subscribe(new JedisPubSub() {

@Override

public void onMessage(String channel, String message) {

System.out.println("Received [" + channel + "]: " + message);

}

}, "news");

---

## 小结

- Pub/Sub 实现了 1:N 的实时消息广播。
- 消息不持久化，订阅者离线会丢失消息。
- 适合聊天、通知、配置刷新等场景。
- 生产环境中如需可靠消息传递，建议使用 Redis Stream 或专业 MQ。
