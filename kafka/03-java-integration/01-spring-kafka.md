# Spring Kafka 集成

Spring Kafka 是 Spring 生态中对 Kafka 的封装，提供了 `KafkaTemplate`、`@KafkaListener` 等便捷组件。

---

## 一、引入依赖
xml

<dependency>

<groupId>org.springframework.kafka</groupId>

<artifactId>spring-kafka</artifactId>

</dependency>

---

## 二、配置（application.yml）
yaml

spring:

kafka:

bootstrap-servers: localhost:9092

producer:

key-serializer: org.apache.kafka.common.serialization.StringSerializer

value-serializer: org.apache.kafka.common.serialization.StringSerializer

acks: all

retries: 3

consumer:

group-id: my-group

key-deserializer: org.apache.kafka.common.serialization.StringDeserializer

value-deserializer: org.apache.kafka.common.serialization.StringDeserializer

auto-offset-reset: earliest

enable-auto-commit: false

listener:

ack-mode: manual_immediate

---

## 三、生产者（KafkaTemplate）
java

@Service

public class KafkaProducer {

@Autowired

private KafkaTemplate<String, String> kafkaTemplate;

public void send(String topic, String message) {
kafkaTemplate.send(topic, message);
}

public void send(String topic, String key, String message) {
kafkaTemplate.send(topic, key, message);
}

// 异步回调
public void sendWithCallback(String topic, String message) {
ListenableFuture<SendResult<String, String>> future = kafkaTemplate.send(topic, message);
future.addCallback(new ListenableFutureCallback<>() {
@Override
public void onSuccess(SendResult<String, String> result) {
log.info("发送成功: {}", result.getRecordMetadata().offset());
}
@Override
public void onFailure(Throwable ex) {
log.error("发送失败", ex);
}
});
}
}

---

## 四、消费者（@KafkaListener）
java

@Component

public class KafkaConsumer {

@KafkaListener(topics = "test", groupId = "my-group")
public void listen(ConsumerRecord<String, String> record, Acknowledgment ack) {
try {
log.info("收到消息: key={}, value={}, offset={}", record.key(), record.value(), record.offset());
// 处理业务
ack.acknowledge(); // 手动提交 offset
} catch (Exception e) {
log.error("消费失败", e);
// 不提交，下次重新消费
}
}
}

### 批量消费
java

@KafkaListener(topics = "test", groupId = "my-group", containerFactory = "batchFactory")

public void listenBatch(List<ConsumerRecord<String, String>> records, Acknowledgment ack) {

for (ConsumerRecord<String, String> record : records) {

// 处理

}

ack.acknowledge();

}

配置批量工厂：
java

@Bean

public ConcurrentKafkaListenerContainerFactory<String, String> batchFactory(

ConsumerFactory<String, String> consumerFactory) {

ConcurrentKafkaListenerContainerFactory<String, String> factory =

new ConcurrentKafkaListenerContainerFactory<>();

factory.setConsumerFactory(consumerFactory);

factory.setBatchListener(true); // 启用批量

factory.getContainerProperties().setAckMode(ContainerProperties.AckMode.MANUAL_IMMEDIATE);

return factory;

}

---

## 五、自定义序列化/反序列化

### 发送 JSON 对象
java

// 配置 JSON 序列化

@Bean

public ProducerFactory<String, Object> producerFactory() {

Map<String, Object> props = new HashMap<>();

props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");

props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);

props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, JsonSerializer.class);

return new DefaultKafkaProducerFactory<>(props);

}

### 消费 JSON
java

// 配置 JSON 反序列化

@Bean

public ConsumerFactory<String, Order> consumerFactory() {

Map<String, Object> props = new HashMap<>();

props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");

props.put(ConsumerConfig.GROUP_ID_CONFIG, "order-group");

props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);

props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, JsonDeserializer.class);

props.put(JsonDeserializer.TRUSTED_PACKAGES, "*");

return new DefaultKafkaConsumerFactory<>(props);

}

---

## 六、重试与死信队列
java

@Bean

public ConcurrentKafkaListenerContainerFactory<String, String> retryFactory(

ConsumerFactory<String, String> consumerFactory) {

ConcurrentKafkaListenerContainerFactory<String, String> factory =

new ConcurrentKafkaListenerContainerFactory<>();

factory.setConsumerFactory(consumerFactory);

// 重试 3 次，间隔 1 秒

factory.setRetryTemplate(new RetryTemplate() {{

setBackOffPolicy(new FixedBackOffPolicy() {{

setBackOffPeriod(1000);

}});

}});

// 重试失败后发送到死信 Topic

factory.setRecoveryCallback(context -> {

ConsumerRecord<?, ?> record = (ConsumerRecord<?, ?>) context.getAttribute("record");

kafkaTemplate.send("test.DLT", record.value().toString());

return null;

});

return factory;

}

---

## 小结

- Spring Kafka 简化了生产者和消费者的开发。
- 推荐手动提交 offset，配合重试和死信队列。
- 批量消费可提升吞吐，但要注意处理时长。
