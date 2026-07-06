# Redis 简介与安装

## 什么是 Redis？

Redis（Remote Dictionary Server）是一个开源的、基于内存的 **key-value 结构** 的非关系型数据库。它支持多种数据结构（字符串、哈希、列表、集合、有序集合等），并提供持久化、复制、集群、事务、Lua 脚本等功能。

### 核心特点
- **纯内存操作**：读写速度极快（每秒可达 10 万+ QPS）。
- **单线程模型**：避免锁竞争，原子性操作天然支持。
- **丰富的数据结构**：不仅仅是 String，还有 Hash、List、Set、ZSet 等。
- **持久化**：RDB（快照）和 AOF（追加日志）两种方式。
- **高可用**：主从复制 + Sentinel 哨兵。
- **分布式**：Redis Cluster 自动分片。

### 应用场景
- **缓存**：减轻数据库压力（最常用）。
- **分布式锁**：基于 SETNX 或 Redisson。
- **计数器**：如点赞数、访问量（INCR 命令）。
- **排行榜**：ZSet 的有序特性。
- **消息队列**：List 的阻塞读取或 Stream。
- **Session 共享**：替代 Tomcat Session。

---

## 安装 Redis

### Linux（Ubuntu / CentOS）

bash

Ubuntu

sudo apt update

sudo apt install redis-server

CentOS

sudo yum install epel-release

sudo yum install redis

启动服务

sudo systemctl start redis

sudo systemctl enable redis

检查是否运行

redis-cli ping

应返回 PONG
### macOS（Homebrew）

bash

brew install redis

brew services start redis

redis-cli ping

### Windows（WSL 或 官方 MSI）

推荐使用 WSL（Windows Subsystem for Linux）安装 Linux 版本，或下载 Redis for Windows 的 MSI 安装包（社区维护）。

### Docker 安装（推荐学习用）

bash

docker run --name myredis -d -p 6379:6379 redis

docker exec -it myredis redis-cli

---

## 启动与连接

### 启动 Redis 服务

bash

redis-server /path/to/redis.conf

默认端口 6379，可通过 `--port` 指定。

### 连接 Redis

bash

redis-cli -h 127.0.0.1 -p 6379 -a yourpassword

- `-h`：主机地址，默认 127.0.0.1
- `-p`：端口，默认 6379
- `-a`：密码（如果设置了 requirepass）

### 测试基本命令

bash

127.0.0.1:6379> SET name "Redis"

OK

127.0.0.1:6379> GET name

"Redis"

127.0.0.1:6379> EXPIRE name 10

(integer) 1

127.0.0.1:6379> TTL name

(integer) 7

---

## 停止 Redis

bash

redis-cli shutdown

或 kill 进程
---

## 配置文件 redis.conf 快速入门

Redis 的配置文件位于 `/etc/redis/redis.conf`（Linux）或安装目录下。常用配置项：

ini

绑定 IP（只允许本机访问）

bind 127.0.0.1

端口

port 6379

守护进程模式（后台运行）

daemonize yes

密码

requirepass yourpassword

最大内存（单位字节）

maxmemory 256mb

内存淘汰策略

maxmemory-policy allkeys-lru

---

## 图形化管理工具

- **Redis Desktop Manager**（免费版有限制）
- **Another Redis Desktop Manager**（开源免费）
- **Medis**（macOS 美观）
- **命令行**：`redis-cli` 足够强大

---

## 小结

- Redis 是基于内存的 NoSQL 数据库，速度快、数据结构丰富。
- 安装方式多样，推荐使用 Docker 快速上手。
- 学会启动、连接、执行基本命令。
- 配置文件是关键，需要了解常用参数。