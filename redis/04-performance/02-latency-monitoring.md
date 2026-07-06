# Redis 延迟监控与分析

延迟是衡量 Redis 性能的关键指标。Redis 提供了内置的延迟监控工具，帮助我们定位慢操作。

---

## 一、延迟的来源

| 来源 | 说明 |
|------|------|
| 网络延迟 | 客户端到服务器的往返时间（RTT） |
| 慢查询 | 执行时间超过阈值的命令 |
| Fork 阻塞 | BGSAVE / BGREWRITEAOF 时 fork 子进程 |
| 大 key 操作 | 操作大集合（如 SMEMBERS、LRANGE 百万级） |
| 内存交换（Swap） | 物理内存不足，数据被换到磁盘 |
| AOF 同步 | appendfsync always 策略下每次写操作都 fsync |
| CPU 争抢 | 虚拟机或共享宿主机的 CPU 资源竞争 |
| 过期 key 删除 | 主动删除大量过期 key 可能短暂卡顿 |

---

## 二、内置延迟监控工具

### 1. LATENCY 命令系列（Redis 2.8.13+）
bash

查看延迟事件类型
LATENCY LATEST

查看历史延迟记录（最近 160 条）
LATENCY HISTORY command

查看延迟事件的统计摘要
LATENCY SUMMARY

重置延迟记录
LATENCY RESET [event ...]

图形化显示延迟分布
LATENCY GRAPH event

支持的延迟事件类型：
- `command`：慢查询（超过 slowlog-log-slower-than 的命令）
- `fork`：fork 子进程的阻塞时间
- `aof-write`：AOF 写入磁盘的延迟
- `expire-cycle`：过期 key 清理周期的耗时
- `eviction-cycle`：内存淘汰周期的耗时

### 2. 使用 redis-cli 测量延迟
bash

测量网络延迟（连续 PING 10 次）
redis-cli --latency -h 127.0.0.1 -p 6379

输出：min: 0, max: 1, avg: 0.24 (毫秒)
持续监控延迟
redis-cli --latency-history -i 1

查看服务端时间消耗分布
redis-cli --stat

### 3. SLOWLOG 慢查询日志
bash

设置慢查询阈值（微秒，10000 = 10ms）
CONFIG SET slowlog-log-slower-than 10000

查看最近 10 条慢查询
SLOWLOG GET 10

查看慢查询数量
SLOWLOG LEN

重置慢查询日志
SLOWLOG RESET

---

## 三、第三方监控工具

### 1. RedisInsight（官方 GUI）
- 可视化查看延迟、CPU、内存、慢查询等。
- 支持实时监控和历史趋势分析。

### 2. Prometheus + Grafana
- 通过 `redis_exporter` 采集 Redis 指标。
- 配置告警规则（如延迟超过 100ms 报警）。

### 3. 云服务商的监控
- 阿里云 Redis 提供性能监控、慢查询分析、大 key 分析等。
- AWS ElastiCache 提供 CloudWatch 指标。

---

## 四、常见延迟问题排查

### 1. 网络延迟高
bash

测试网络延迟
ping redis-host

如果 > 1ms，考虑同区域部署
### 2. Fork 阻塞时间长
bash

查看 fork 耗时
LATENCY HISTORY fork

如果 > 100ms，说明内存过大，考虑拆分实例
### 3. 大 key 导致慢查询
bash

查找大 key
redis-cli --bigkeys

查看某个 key 的具体大小
MEMORY USAGE mykey

### 4. 内存交换（Swap）
bash

检查是否使用了 swap
cat /proc/$(pidof redis-server)/status | grep VmSwap

如果 > 0，说明内存不足，需要扩容或优化
### 5. AOF 同步延迟
bash

检查 AOF 策略
CONFIG GET appendfsync

如果是 always，改为 everysec 可大幅降低延迟
---

## 五、降低延迟的最佳实践

1. **使用 Pipeline**：批量操作减少网络往返。
2. **启用连接池**：复用连接，避免频繁创建/销毁。
3. **合理设置超时**：`timeout 300` 避免空闲连接占用资源。
4. **禁用危险命令**：`rename-command KEYS ""` 避免阻塞。
5. **控制大 key**：拆分大集合（如分片存储）。
6. **选择合适的持久化策略**：`appendfsync everysec` 平衡性能和安全。
7. **使用非阻塞操作**：如 `SCAN` 代替 `KEYS`，`SSCAN` 代替 `SMEMBERS`。
8. **硬件优化**：使用 SSD、充足的内存、高速网络。

---

## 六、延迟基线

| 场景 | 合理延迟（平均值） |
|------|-------------------|
| 同机房的 Redis | < 0.5ms |
| 同区域的 Redis | < 2ms |
| 跨区域的 Redis | > 10ms（不建议） |
| 单命令执行 | < 1ms |
| Pipeline 批量 | 取决于命令数，通常 < 5ms |

---

## 小结

- 延迟监控是 Redis 运维的必修课，使用内置的 `LATENCY`、`SLOWLOG` 和 `--latency` 工具。
- 常见延迟问题包括网络、fork、大 key、swap 等。
- 优化方向：减少网络往返、控制大 key、合理配置持久化和淘汰策略。
