# Redis 学习路线 · 从入门到实战

> 本专题是 `java-backend-roadmap` 的重要组成部分，旨在帮助你系统掌握 Redis 的核心概念、高级特性、集群方案、Java 集成以及常见业务场景下的最佳实践。

---

## 🎯 学习目标

完成本专题后，你将能够：

- ✅ 理解 Redis 的基本数据结构及其适用场景
- ✅ 熟练使用常用命令，独立搭建单机/集群环境
- ✅ 掌握持久化（RDB/AOF）、主从复制、哨兵、Cluster 的原理与配置
- ✅ 使用 Java 客户端（Jedis/Lettuce/Redisson）操作 Redis
- ✅ 结合 Spring Boot 实现缓存、分布式锁、Session 共享等典型功能
- ✅ 应对面试中 90% 以上的 Redis 相关问题

---

## 📖 前置知识

- Java 基础语法
- Linux 基本操作（命令行、文件编辑）
- 了解基本的计算机网络（TCP/IP）
- （可选）Spring Boot 基础

---

## 📂 目录说明

| 目录 | 内容 | 难度 |
|------|------|------|
| `01-basics/` | 安装启动、五大数据类型、命令速查、配置 | ⭐ 入门 |
| `02-advanced/` | 持久化、事务、Lua、发布订阅、Stream、Pipeline、GEO | ⭐⭐ 进阶 |
| `03-cluster/` | 主从、Sentinel、Cluster、代理方案 | ⭐⭐⭐ 高阶 |
| `04-performance/` | 内存优化、BigKey/HotKey、慢查询、延迟监控 | ⭐⭐⭐ 高阶 |
| `05-java-integration/` | Jedis/Lettuce/Redisson、Spring Data Redis、连接池 | ⭐⭐ 进阶 |
| `06-scenarios/` | Session共享、分布式锁、限流、缓存策略、排行榜、消息队列、布隆过滤器 | ⭐⭐⭐ 实战 |
| `07-interview/` | 常见面试题与真实案例分析 | ⭐⭐⭐ 冲刺 |

---

## 🚀 学习路线建议

### 第一阶段：基础入门（2~3天）
1. 阅读 `01-basics/01-introduction.md`，安装并启动 Redis。
2. 学习五种基本数据类型（String、Hash、List、Set、ZSet），动手敲命令。
3. 熟悉常用命令（`SET/GET`、`HSET/HGET`、`LPUSH/LPOP`、`SADD/SMEMBERS`、`ZADD/ZRANGE` 等）。
4. 了解 Redis 配置文件（`redis.conf`）的关键参数。

### 第二阶段：进阶特性（3~4天）
1. 理解 RDB 和 AOF 持久化原理，配置并测试备份恢复。
2. 学习事务与 Lua 脚本，对比两者的原子性差异。
3. 尝试发布订阅和 Stream 消息队列，理解其应用场景。
4. 掌握 Pipeline 批量操作和 GEO 地理位置计算。

### 第三阶段：集群与高可用（3~4天）
1. 搭建主从复制环境，理解读写分离。
2. 配置 Sentinel 哨兵实现自动故障转移。
3. 搭建 Redis Cluster 集群（至少 6 节点），体验分片与高可用。
4. 了解代理方案（Twemproxy/Codis）的优缺点。

### 第四阶段：Java 集成（2~3天）
1. 使用 Jedis 完成基础 CRUD 操作。
2. 切换到 Lettuce（Spring Boot 2.x 默认客户端），对比异步性能。
3. 学习 Redisson 的分布式锁、分布式集合等高级功能。
4. 在 Spring Boot 项目中整合 `spring-boot-starter-data-redis`，并用 `@Cacheable` 实现缓存。

### 第五阶段：实战场景（3~5天）
1. 实现分布式锁（Redisson + SETNX 两种方式）。
2. 设计缓存穿透/击穿/雪崩的解决方案（布隆过滤器、互斥锁、永不过期+异步更新）。
3. 使用 ZSet 实现排行榜（如积分排名、热搜榜单）。
4. 使用 List 或 Stream 实现轻量级消息队列。
5. 实现接口限流（滑动窗口算法）。

### 第六阶段：面试准备（1~2天）
1. 复习 `07-interview/` 中的常见问题。
2. 重点准备：缓存一致性、分布式锁、持久化选择、集群脑裂、BigKey 危害等。
3. 结合苍穹外卖项目中的 Redis 实践（缓存菜品、店铺状态）进行总结。

---

## 🔗 关联项目

本专题的理论知识将在以下项目中得到实践：

- **[苍穹外卖](../projects/sky-take-out/README.md)** — 使用 Redis 缓存菜品/套餐数据，存储店铺营业状态，实现分布式锁防止重复下单。
- *更多项目待添加...*

---

## 📚 推荐资源

- [Redis 官方文档](https://redis.io/docs/) — 最权威的参考资料
- [Redis 命令参考（中文）](https://redis.com.cn/commands.html) — 命令速查
- 《Redis 设计与实现》（黄健宏）— 原理深度解读
- 《Redis 实战》（Josiah L. Carlson）— 场景案例丰富

---

## 🤝 贡献指南

欢迎通过 Issue 或 PR 补充内容、修正错误。请确保：

- 文件命名使用英文，语义清晰
- Markdown 格式规范，代码块标明语言
- 图片放入 `assets/images/` 目录

---

java-backend-roadmap/
├── notes/
│   ├── redis/                          ← Redis 专题
│   │   ├── README.md                   # 本专题总览
│   │   ├── 01-basics/                  # 基础入门
│   │   │   ├── 01-introduction.md      # Redis 简介、安装、启动
│   │   │   ├── 02-data-types.md        # 五大基本数据类型（String, Hash, List, Set, ZSet）
│   │   │   ├── 03-commands.md          # 常用命令速查
│   │   │   └── 04-configuration.md     # 配置文件详解
│   │   ├── 02-advanced/                # 进阶特性
│   │   │   ├── 01-persistence.md       # RDB 与 AOF 持久化
│   │   │   ├── 02-transactions.md      # 事务与 Lua 脚本
│   │   │   ├── 03-pub-sub.md           # 发布订阅
│   │   │   ├── 04-streams.md           # Stream 消息队列
│   │   │   ├── 05-pipeline.md          # 管道（Pipeline）
│   │   │   └── 06-geo.md               # GEO 地理位置
│   │   ├── 03-cluster/                 # 集群与高可用
│   │   │   ├── 01-sentinel.md          # Redis Sentinel 哨兵
│   │   │   ├── 02-cluster.md           # Redis Cluster 集群
│   │   │   ├── 03-replication.md       # 主从复制
│   │   │   └── 04-proxy.md             # Twemproxy / Codis 等代理方案
│   │   ├── 04-performance/             # 性能优化
│   │   │   ├── 01-memory-optimization.md # 内存优化策略
│   │   │   ├── 02-latency-monitoring.md  # 延迟监控与分析
│   │   │   ├── 03-bigkey-hotkey.md       # BigKey 与 HotKey 处理
│   │   │   └── 04-slowlog.md             # 慢查询日志
│   │   ├── 05-java-integration/        # Java 集成
│   │   │   ├── 01-jedis.md             # Jedis 客户端
│   │   │   ├── 02-lettuce.md           # Lettuce 客户端
│   │   │   ├── 03-redisson.md          # Redisson 分布式对象与锁
│   │   │   ├── 04-spring-data-redis.md # Spring Data Redis 与 Spring Cache
│   │   │   └── 05-connection-pool.md   # 连接池配置
│   │   ├── 06-scenarios/               # 实战场景
│   │   │   ├── 01-session-share.md     # Session 共享
│   │   │   ├── 02-distributed-lock.md  # 分布式锁（Redisson + SETNX）
│   │   │   ├── 03-rate-limiter.md      # 限流（滑动窗口、令牌桶）
│   │   │   ├── 04-cache-strategy.md    # 缓存穿透、击穿、雪崩解决方案
│   │   │   ├── 05-leaderboard.md       # 排行榜（ZSet）
│   │   │   ├── 06-message-queue.md     # 消息队列（List / Stream）
│   │   │   └── 07-bloom-filter.md      # 布隆过滤器
│   │   ├── 07-interview/               # 面试突击
│   │   │   ├── 01-faq-basic.md         # 基础常见面试题
│   │   │   ├── 02-faq-advanced.md      # 进阶面试题
│   │   │   └── 03-real-case.md         # 真实大厂面试场景分析
│   │   └── assets/                     # 图片、PDF 等资源
│   │       └── images/
│   └── ...                             # 其他专题（MySQL、JVM、Spring 等）
├── projects/
│   └── sky-take-out/                   # 苍穹外卖项目（已包含 Redis 实践）
└── README.md                           # 总入口

*Happy Coding! 🚀*