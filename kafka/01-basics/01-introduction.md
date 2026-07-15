# Kafka 简介与核心概念

## 什么是 Kafka？

Apache Kafka 是一个分布式流处理平台，最初由 LinkedIn 开发，后捐献给 Apache 基金会。它的核心能力是**发布-订阅消息系统**，但远比传统消息队列强大：高吞吐、持久化、分布式、支持流处理。

### 核心特点
- **高吞吐**：单机可达数十万 TPS，适合大数据场景。
- **持久化**：消息落盘，可配置保留时间（如 7 天），支持回溯消费。
- **分布式**：天生集群，分区副本保证高可用。
- **顺序性**：分区内消息有序，全局无序。
- **流处理**：Kafka Streams 提供实时流处理能力。

### 应用场景
- 日志收集（ELK 套件常用 Kafka 做缓冲）。
- 消息系统（解耦微服务）。
- 用户活动跟踪（埋点数据）。
- 流处理（实时计算）。
- 事件溯源。

---

## 核心概念

| 概念 | 说明 |
|------|------|
| **Broker** | Kafka 服务器节点，一个集群由多个 Broker 组成。 |
| **Topic** | 消息的主题，类似数据库的表。 |
| **Partition** | Topic 的分区，每个分区是一个有序的日志文件。 |
| **Producer** | 消息生产者，向 Topic 发送消息。 |
| **Consumer** | 消息消费者，从 Topic 拉取消息。 |
| **Consumer Group** | 消费者组，组内消费者共同消费一个 Topic，每条消息只被组内一个消费者消费。 |
| **Offset** | 消息在分区内的偏移量，唯一标识一条消息。 |
| **Replica** | 副本，每个分区有多个副本（Leader/Follower）。 |
| **ISR** | In-Sync Replicas，与 Leader 保持同步的副本集合。 |
| **ZooKeeper / KRaft** | 元数据管理，早期依赖 ZooKeeper，新版逐渐用 KRaft 替代。 |

---

## 安装与启动（Docker 快速体验）

bash

使用 Docker Compose 启动单节点 Kafka（含 ZooKeeper）

version: '3'

services:

zookeeper:

image: confluentinc/cp-zookeeper:latest

environment:

ZOOKEEPER_CLIENT_PORT: 2181

kafka:

image: confluentinc/cp-kafka:latest

depends_on:

zookeeper

ports:

"9092:9092"

environment:

KAFKA_BROKER_ID: 1

KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181

KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092

KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1

bash

docker-compose up -d

### 验证
bash

进入容器

docker exec -it kafka bash

创建 Topic

kafka-topics --create --topic test --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092

查看 Topic 列表

kafka-topics --list --bootstrap-server localhost:9092

发送消息

kafka-console-producer --topic test --bootstrap-server localhost:9092

hello

world

消费消息（从开始）

kafka-console-consumer --topic test --from-beginning --bootstrap-server localhost:9092

## 小结

- Kafka 是分布式流平台，核心是发布-订阅消息。
- 理解 Topic、Partition、Consumer Group 是基础。
- 用 Docker 可以快速搭建学习环境。