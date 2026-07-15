# 日志收集场景

Kafka 最常见的用途之一是作为日志收集的缓冲层，配合 ELK（Elasticsearch、Logstash、Kibana）使用。

---

## 一、架构
应用服务 → Kafka → Logstash → Elasticsearch → Kibana

- 应用服务将日志发送到 Kafka。
- Logstash 从 Kafka 消费日志，处理后写入 Elasticsearch。
- Kibana 提供可视化查询。

---

## 二、实现

### 应用端发送日志（使用 logback + kafka appender）
xml

<appender name="KAFKA" class="com.github.danielwegener.logback.kafka.KafkaAppender">

<encoder>

<pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>

</encoder>

<topic>app-logs</topic>

<keyingStrategy class="com.github.danielwegener.logback.kafka.keying.HostNameKeyingStrategy" />

<deliveryStrategy class="com.github.danielwegener.logback.kafka.delivery.AsynchronousDeliveryStrategy" />

<producerConfig>bootstrap.servers=localhost:9092</producerConfig>

</appender>

<root level="INFO">

<appender-ref ref="KAFKA" />

</root>

### Logstash 配置
ruby

input {

kafka {

bootstrap_servers => "localhost:9092"

topics => ["app-logs"]

group_id => "logstash"

codec => "json"

}

}

output {

elasticsearch {

hosts => ["localhost:9200"]

index => "app-logs-%{+YYYY.MM.dd}"

}

}

---

## 三、优势

- **解耦**：应用只负责发日志，不关心下游处理。
- **缓冲**：Kafka 可承受日志峰值，避免 Logstash 或 ES 被冲垮。
- **持久化**：日志可保留一段时间，方便回溯。

---

## 四、注意事项

- 日志量较大时，合理设置分区数和保留时间。
- 使用异步发送，避免日志影响业务性能。
- 监控 Kafka 的磁盘使用和消费 lag。