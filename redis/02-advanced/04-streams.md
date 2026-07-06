# Redis Streams：消息队列与事件流

Redis Streams 是 Redis 5.0 引入的一种新的数据结构，用于实现**消息队列**和**事件流**。它弥补了 Pub/Sub 的不足（消息持久化、消费者组、ACK 机制）。

---

## 一、为什么需要 Streams？

- Pub/Sub 消息不持久化，消费者离线丢失消息。
- List 作为队列虽然支持阻塞读取，但缺乏消费者组、消息确认等高级功能。
- 需要一个**持久化、可靠、支持多消费者组**的消息队列。

---

## 二、核心概念

- **Stream**：一个有序的消息链表，每条消息有一个唯一的 ID（通常是 `timestamp-sequence`）。
- **Consumer Group**：消费者组，组内消费者共同消费消息，每条消息只会被组内一个消费者消费。
- **Consumer**：组内的消费者实例。
- **Pending Entries List (PEL)**：已投递但未确认的消息列表，用于实现消息重试。

---

## 三、常用命令

### 生产消息
| 命令 | 作用 |
|------|------|
| `XADD key [NOMKSTREAM] [MAXLEN [~] threshold] [MINID [~] threshold] [LIMIT count] *\|id field value [field value...]` | 添加消息到 Stream |
| `XLEN key` | 获取 Stream 长度 |
| `XRANGE key start end [COUNT count]` | 按 ID 范围获取消息 |
| `XREVRANGE key end start [COUNT count]` | 反向获取消息 |
| `XREAD [COUNT count] [BLOCK milliseconds] STREAMS key [key...] id [id...]` | 读取消息（阻塞或非阻塞） |
| `XGROUP CREATE key groupname id-or-$ [MKSTREAM]` | 创建消费者组 |
| `XREADGROUP GROUP group consumer [COUNT count] [BLOCK milliseconds] [NOACK] STREAMS key [key...] id [id...]` | 消费者组读取消息 |
| `XACK key group id [id...]` | 确认消息已处理 |
| `XPENDING key group [[start end count] [consumer]]` | 查看待确认消息 |
| `XCLAIM key group consumer min-idle-time id [id...] [JUSTID] [LASTID lastid] [RETRYCOUNT count]` | 转移消息所有权（消息超时重分配） |
| `XDEL key id [id...]` | 删除消息 |
| `XTRIM key MAXLEN [~] threshold [MINID [~] threshold [LIMIT count]]` | 裁剪 Stream |
| `XINFO key [group\|consumers\|stream]` | 查看 Stream 信息 |

---

## 四、基本使用示例

### 1. 生产消息

bash

添加消息，* 表示自动生成 ID

127.0.0.1:6379> XADD mystream * name Alice age 30

"1712345678000-0"

127.0.0.1:6379> XADD mystream * name Bob age 25

"1712345678001-0"

### 2. 读取消息（非阻塞）

bash

从 ID 0 开始读取前 2 条

127.0.0.1:6379> XRANGE mystream - + COUNT 2

"1712345678000-0"

"name"

"Alice"

"age"

"30"

"1712345678001-0"

"name"

"Bob"

"age"

"25"

### 3. 阻塞读取（类似 BLPop）

bash

$ 表示只读取新消息

XREAD BLOCK 0 STREAMS mystream $

### 4. 消费者组

bash

创建消费者组，$ 表示从最新消息开始消费

XGROUP CREATE mystream mygroup $

消费者组内读取（c1 是消费者名称）

XREADGROUP GROUP mygroup c1 COUNT 1 BLOCK 0 STREAMS mystream >

确认消息

XACK mystream mygroup 1712345678000-0

---

## 五、消费者组工作原理

+----------+

| Producer |

+----+-----+

|

XADD    |

v

+--------+--------+

|   Stream        |

| (消息列表)       |

+--------+--------+

|

+---------------+---------------+

|                               |

XREADGROUP                           XREADGROUP

+------+------+                  +------+------+

| Consumer G1 |                  | Consumer G2 |

+------+------+                  +------+------+

|        |                       |        |

c1:msg1  c2:msg2                c3:msg1  c4:msg2

- 每个消费者组有独立的游标，组内消息互不干扰。
- 同组内，每条消息只会被一个消费者消费（负载均衡）。
- 消费者处理完消息后需要 `XACK` 确认，否则消息会留在 PEL 中等待重新投递。

---

## 六、应用场景

### 1. 可靠消息队列
替代 List 实现的队列，支持 ACK 和重试。

### 2. 事件溯源
记录用户操作、订单状态变更等事件流，可用于审计或重建状态。

### 3. 多消费者组
同一个 Stream 可以被不同业务组独立消费（如订单组、通知组）。

### 4. 延迟消息
通过消息 ID 的时间戳部分，可以实现简单的延迟队列（消费者按 ID 范围读取）。

---

## 七、Java 集成示例（Lettuce）

java

// 生产者

RedisCommands<String, String> commands = connection.sync();

commands.xadd("orders", Map.of("userId", "1001", "amount", "99.9"));

// 消费者组

commands.xgroupCreate("orders", "payment-group", "$", true);

// 消费

List<StreamMessage<String, String>> messages = commands.xreadgroup(

Consumer.from("payment-group", "consumer-1"),

StreamOffset.lastConsumed("orders"));

for (StreamMessage<String, String> msg : messages) {

System.out.println(msg.getBody());

commands.xack("orders", "payment-group", msg.getId());

}

---

## 八、Streams vs Pub/Sub vs List

| 特性 | Pub/Sub | List | Streams |
|------|---------|------|---------|
| 消息持久化 | ❌ | ✅ | ✅ |
| 消费者组 | ❌ | ❌ | ✅ |
| 消息确认 | ❌ | ❌ | ✅（ACK） |
| 消息回溯 | ❌ | 有限（LRANGE） | ✅（按 ID 范围） |
| 阻塞读取 | ✅ | ✅（BLPop） | ✅（XREAD BLOCK） |
| 复杂度 | 低 | 低 | 中等 |

**结论**：Streams 是 Redis 中最强大的消息队列实现，适用于大多数需要可靠消息传递的场景。

---

## 小结

- Streams 是持久化、支持消费者组的消息队列。
- 核心操作：XADD（生产）、XREADGROUP（消费）、XACK（确认）。
- 适用于需要可靠投递、多消费者组、消息回溯的场景。
- 在苍穹外卖中，如果未来需要解耦订单处理和通知，可以用 Streams 替代当前的同步调用。