# Kafka 学习路线 · 从入门到实战

> 本专题是 `java-backend-roadmap` 的独立组件，帮助你系统掌握 Kafka 的核心概念、Java 集成、实战场景以及面试高频问题。

---

## 🎯 学习目标

- ✅ 理解 Kafka 的基本概念：Topic、Partition、Producer、Consumer、Broker、Consumer Group
- ✅ 掌握 Kafka 的副本机制、ISR、acks 等可靠性配置
- ✅ 能够在 Spring Boot 中集成 Kafka 实现消息收发
- ✅ 理解 Kafka 如何保证消息不丢失、不重复、顺序性
- ✅ 对比 Kafka、RabbitMQ、Redis Stream 的选型差异
- ✅ 应对面试中 90% 以上的 Kafka 相关问题

---

## 📖 前置知识

- Java 基础
- Linux 基本操作
- （可选）了解消息队列的基本概念

---

## 📂 目录说明

| 目录 | 内容 | 难度 |
|------|------|------|
| `01-basics/` | Topic、Partition、Producer、Consumer、Broker、Consumer Group、Offset | ⭐ 入门 |
| `02-advanced/` | 副本机制、ISR、acks、幂等性、事务、Exactly-Once 语义 | ⭐⭐ 进阶 |
| `03-java-integration/` | Spring Kafka 集成、Producer/Consumer API、序列化、重试 | ⭐⭐ 进阶 |
| `04-scenarios/` | 日志收集、异步解耦、削峰填谷、流处理（Kafka Streams） | ⭐⭐⭐ 实战 |
| `05-compare/` | Kafka vs RabbitMQ vs Redis Stream vs RocketMQ | ⭐⭐ 选型 |
| `06-interview/` | 常见面试题与真实案例分析 | ⭐⭐⭐ 冲刺 |

---

## 🚀 学习路线建议

### 第一阶段：基础入门（2~3 天）
1. 阅读 `01-basics/`，理解 Kafka 的架构和核心概念。
2. 搭建 Kafka 环境（推荐 Docker 一键启动）。
3. 使用命令行工具创建 Topic、发送和消费消息。

### 第二阶段：进阶特性（2~3 天）
1. 理解副本机制、ISR、Leader 选举。
2. 配置 acks、retries、幂等性，理解消息可靠性。
3. 学习 Kafka 事务和 Exactly-Once 语义。

### 第三阶段：Java 集成（2~3 天）
1. 在 Spring Boot 项目中引入 `spring-kafka`。
2. 实现 Producer 和 Consumer，配置序列化/反序列化。
3. 实现消息重试、死信队列、批量消费。

### 第四阶段：实战场景（2~3 天）
1. 设计一个日志收集系统（模拟）。
2. 设计一个订单异步处理流程（解耦）。
3. 了解 Kafka Streams 的基本用法。

### 第五阶段：面试准备（1~2 天）
1. 复习 `06-interview/` 中的常见问题。
2. 重点准备：消息不丢失、顺序性、重复消费、分区策略、Rebalance。

---

## 🔗 关联内容

- [Redis Stream 消息队列](../notes/redis/02-advanced/04-streams.md) — 轻量级 MQ 对比
- [苍穹外卖](../projects/sky-take-out/README.md) — 可尝试引入 Kafka 替代部分同步调用

---

## 📚 推荐资源

- [Kafka 官方文档](https://kafka.apache.org/documentation/)
- 《深入理解 Kafka：核心设计与实践原理》（朱忠华）
- 《Kafka 权威指南》（Neha Narkhede 等）

---

## 🤝 贡献指南

欢迎通过 Issue 或 PR 补充内容。请确保：
- 文件命名使用英文，语义清晰
- Markdown 格式规范，代码块标明语言
- 图片放入 `assets/images/` 目录

---

*Happy Coding! 🚀*