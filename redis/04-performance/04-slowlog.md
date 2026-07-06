# Redis 慢查询日志

慢查询日志是排查 Redis 性能问题的第一道防线。它记录了执行时间超过指定阈值的命令。

---

## 一、慢查询的配置
ini

慢查询阈值（微秒，10000 = 10ms）
slowlog-log-slower-than 10000

慢查询日志最大条数（先进先出）
slowlog-max-len 128

- `slowlog-log-slower-than`：命令执行时间超过此值（微秒）才会被记录。设为 0 记录所有命令，设为负数禁用。
- `slowlog-max-len`：最多保留多少条慢查询记录，超出后会丢弃最早的记录。

运行时修改：
bash

CONFIG SET slowlog-log-slower-than 5000

CONFIG SET slowlog-max-len 256

---

## 二、查看慢查询
bash

获取最近 10 条慢查询
SLOWLOG GET 10

获取慢查询总数
SLOWLOG LEN

重置慢查询日志
SLOWLOG RESET

### 输出格式
(integer) 1              # 唯一 ID

(integer) 1712345678     # Unix 时间戳

(integer) 12034          # 执行耗时（微秒）

"KEYS"                # 命令

"*"                   # 参数

"127.0.0.1:54321"        # 客户端地址

"my-db"                  # 数据库名称（如果启用）

---

## 三、慢查询的常见原因

| 命令 | 原因 | 优化方案 |
|------|------|----------|
| `KEYS *` | 扫描所有 key，O(N) | 使用 `SCAN` 代替 |
| `SMEMBERS large_set` | 返回所有元素，O(N) | 使用 `SSCAN` 或拆分集合 |
| `LRANGE list 0 -1` | 返回所有元素，O(N) | 限制范围或分页 |
| `HGETALL large_hash` | 返回所有字段，O(N) | 使用 `HSCAN` 或拆分 |
| `ZRANGE zset 0 -1` | 返回所有元素，O(N) | 限制范围或分页 |
| `SORT` | 排序操作，复杂度高 | 避免在 Redis 中排序 |
| `LUA 脚本` | 脚本执行时间过长 | 优化脚本逻辑，控制循环 |
| `DEL bigkey` | 删除大 key 阻塞 | 使用 `UNLINK` 异步删除 |

---

## 四、如何分析慢查询

### 1. 确定慢查询模式
- 是否集中在某个特定命令上？
- 是否发生在特定时间段（如整点缓存失效）？
- 是否来自特定客户端 IP？

### 2. 关联业务代码
bash

查看慢查询的客户端地址
SLOWLOG GET | grep -A 5 "client-address"

然后在应用日志中查找该 IP 的请求，定位具体业务代码。

### 3. 使用监控工具
- **RedisInsight**：图形化展示慢查询趋势。
- **Prometheus + Grafana**：通过 `redis_slowlog_last_entry_time_seconds` 等指标监控。

---

## 五、慢查询的预防

### 1. 禁用危险命令
ini

rename-command KEYS ""

rename-command FLUSHALL ""

rename-command FLUSHDB ""

rename-command CONFIG ""

### 2. 使用 SCAN 系列命令
bash

替代 KEYS
SCAN 0 MATCH user:* COUNT 100

替代 SMEMBERS
SSCAN myset 0 COUNT 100

替代 HGETALL
HSCAN myhash 0 COUNT 100

替代 ZRANGE（全量）
ZSCAN myzset 0 COUNT 100

### 3. 控制集合大小
- 使用 `LTRIM` 限制 List 长度。
- 使用 `ZREMRANGEBYRANK` 定期清理 ZSet。
- 对 Hash 设置合理的 `hash-max-ziplist-entries`。

### 4. 拆分大 key
参见 BigKey 处理方案。

### 5. 优化 Lua 脚本
- 避免在脚本中使用耗时的循环。
- 控制脚本执行时间（默认 5 秒限制）。
- 使用 `SCRIPT KILL` 终止长时间运行的脚本。

---

## 六、慢查询的告警

### 使用 redis_exporter + Prometheus
yaml

prometheus.yml
scrape_configs:

job_name: 'redis'

static_configs:

targets: ['localhost:9121']

### 告警规则
yaml

groups:

name: redis_alerts

rules:

alert: RedisSlowQueries

expr: rate(redis_slowlog_last_entry_time_seconds[5m]) > 0

for: 1m

labels:

severity: warning

annotations:

summary: "Redis 出现慢查询"

---

## 七、实战案例

**现象**：某电商系统在晚高峰出现大量超时，Redis CPU 飙升至 90%。

**排查**：
1. `SLOWLOG GET 10` 发现大量 `KEYS *` 命令。
2. 追踪客户端 IP，定位到是后台管理系统的“商品列表”页面。
3. 该页面为了显示商品总数，执行了 `KEYS product:*`。

**修复**：
- 改用 `SCAN` 分批扫描。
- 在数据库中维护商品总数，定期同步到 Redis 的一个计数器 key。

**效果**：CPU 降至 30%，超时消失。

---

## 小结

- 慢查询是性能问题的直接证据，合理配置 `slowlog-log-slower-than`（建议 10ms）。
- 重点关注 `KEYS`、全量集合操作、大 key 删除等命令。
- 使用 `SCAN` 系列命令替代全量遍历。
- 结合监控工具实现慢查询告警，及时发现和修复。