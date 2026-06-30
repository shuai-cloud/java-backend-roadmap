# Log Analysis 📋

> Log analysis techniques for Java backend engineers.  
> Java 后端工程师必备的日志分析技能。

---

## 📖 Overview · 概览

This section covers practical log analysis techniques you'll use daily: searching for errors, extracting patterns, aggregating statistics, monitoring in real time, and managing log rotation. Mastering these skills will help you quickly pinpoint production issues and understand application behavior.

本章涵盖日常工作中实用的日志分析技巧：搜索错误、提取模式、聚合统计、实时监控和日志切割管理。掌握这些技能能帮助你快速定位生产问题并理解应用行为。

---

## 🗂️ Techniques · 技巧速查

### 1️⃣ Real-time Log Monitoring · 实时日志监控

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `tail -f` | Follow log file in real time · 实时跟踪日志文件 | `-n 100` 先显示最后100行再跟踪；`-F` 跟踪并处理文件轮转（日志切割时自动重连） |
| `tail -f \| grep` | Filter while following · 实时跟踪并过滤 | `tail -f app.log \| grep ERROR` |
| `tail -f \| awk` | Extract fields while following · 实时跟踪并提取字段 | `tail -f app.log \| awk '/ERROR/ {print $1, $2, $NF}'` |
| `multitail` | Watch multiple log files simultaneously · 同时查看多个日志文件（需安装） | `multitail app1.log app2.log`；支持颜色高亮 |

**注意事项**：
- `tail -F` 比 `tail -f` 更适合生产环境，因为它能处理日志轮转。
- 实时监控时建议加上 `-n 0` 避免刷屏。

---

### 2️⃣ Searching & Filtering · 搜索与过滤

| Technique | Description · 说明 | Example |
|-----------|--------------------|---------|
| Basic grep | 基本搜索 | `grep "ERROR" app.log` |
| Case-insensitive | 忽略大小写 | `grep -i "error" app.log` |
| Count occurrences | 计数 | `grep -c "ERROR" app.log` |
| Context lines | 显示上下文 | `grep -B 5 -A 5 "NullPointerException" app.log` 显示前后5行 |
| Invert match | 反向匹配（排除） | `grep -v "DEBUG" app.log` |
| Recursive search | 递归搜索目录 | `grep -r "ERROR" /var/log/` |
| Extended regex | 扩展正则 | `grep -E "(ERROR|FATAL)" app.log` |
| Perl-compatible regex | Perl兼容正则 | `grep -P "\d{4}-\d{2}-\d{2}" app.log` 匹配日期格式 |

**注意事项**：
- 搜索 Java 异常堆栈时，使用 `grep -A 10 "Exception"` 显示后续行。
- 大量日志文件建议先 `zgrep` 搜索压缩文件。

---

### 3️⃣ Extracting Fields with awk · 使用 awk 提取字段

| Task | Description · 说明 | Example |
|------|--------------------|---------|
| Extract specific column | 提取特定列 | `awk '{print $1, $4}' app.log` 提取时间和级别 |
| Split by delimiter | 按分隔符拆分 | `awk -F ',' '{print $1, $3}' csv.log` |
| Filter by field value | 按字段值过滤 | `awk '$4 == "ERROR"' app.log` |
| Count per category | 按类别计数 | `awk '{count[$4]++} END {for (k in count) print k, count[k]}' app.log` |
| Sum numeric values | 求和 | `awk '{sum += $NF} END {print sum}' response_times.log` |
| Calculate average | 计算平均值 | `awk '{sum += $NF; count++} END {print sum/count}' response_times.log` |

---

### 4️⃣ Transforming with sed · 使用 sed 转换

| Task | Description · 说明 | Example |
|------|--------------------|---------|
| Mask sensitive data | 脱敏敏感数据 | `sed 's/[0-9]\{16\}/****/g' app.log` 隐藏信用卡号 |
| Remove ANSI color codes | 移除颜色代码 | `sed 's/\x1b\[[0-9;]*m//g' colored.log` |
| Keep only certain lines | 只保留特定行 | `sed -n '/ERROR/p' app.log` |
| Replace timestamp format | 替换时间戳格式 | `sed 's/2025-03-15/2025-03-16/g' app.log` |

---

### 5️⃣ Aggregation & Statistics · 聚合与统计

| Task | Description · 说明 | Example |
|------|--------------------|---------|
| Count error types | 统计各类错误数量 | `grep -oP '"errorCode":"\K[^"]+' app.log \| sort \| uniq -c \| sort -rn` |
| Top IP addresses | 统计访问最多的IP | `awk '{print $1}' access.log \| sort \| uniq -c \| sort -rn \| head -10` |
| Response time distribution | 响应时间分布 | `awk '{if($NF > 1000) slow++; else fast++} END {print "Fast:", fast, "Slow:", slow}' response.log` |
| Hourly request count | 按小时统计请求数 | `awk '{print substr($2,1,2)}' access.log \| sort \| uniq -c` |
| Find slowest endpoints | 找出最慢的端点 | `awk '{print $7, $NF}' access.log \| sort -k2 -rn \| head -10` |

---

### 6️⃣ Log Rotation · 日志切割

Logrotate 是 Linux 系统自带的日志轮转工具，配置位于 `/etc/logrotate.conf` 和 `/etc/logrotate.d/`。

**Java 应用日志切割配置示例**（`/etc/logrotate.d/myapp`）：
/var/log/myapp/*.log {

daily

rotate 7

compress

delaycompress

missingok

notifempty

copytruncate

postrotate

systemctl reload myapp > /dev/null 2>&1 || true

endscript

}

**常用指令说明**：

| Directive | Description · 说明 |
|-----------|--------------------|
| `daily` | 每天轮转一次（也可用 `weekly`、`monthly`） |
| `rotate 7` | 保留最近7个归档文件 |
| `compress` | 压缩归档文件（gzip） |
| `delaycompress` | 延迟一天压缩（方便查看当天日志） |
| `missingok` | 日志文件缺失时不报错 |
| `notifempty` | 空文件不轮转 |
| `copytruncate` | 复制并清空原文件（应用无需重启，适合 Java 应用） |
| `postrotate/endscript` | 轮转后执行的命令 |

**手动测试**：
bash

sudo logrotate -d /etc/logrotate.d/myapp   # 调试模式（不实际执行）

sudo logrotate -f /etc/logrotate.d/myapp   # 强制执行

---

### 7️⃣ Common Analysis Scenarios · 常见分析场景

#### Scenario 1: 统计应用启动时间
bash

grep "Started Application" app.log | tail -1 | awk '{print $1, $2}'

#### Scenario 2: 找出 OOM 发生的时间点
bash

grep -B 5 "OutOfMemoryError" app.log | head -10

#### Scenario 3: 统计接口调用次数
bash

grep -oP '"uri":"/\K[^"]+' access.log | sort | uniq -c | sort -rn | head -10

#### Scenario 4: 查找慢 SQL（假设日志格式为 `[SQL] SELECT ... took 1234ms`）
bash

grep -oP 'took \K\d+' app.log | awk '{if($1 > 1000) print}'

#### Scenario 5: 统计每小时的错误数
bash

awk '/ERROR/ {hour=substr($2,1,2); count[hour]++} END {for(h in count) print h":00", count[h]}' app.log | sort

---

## 🚀 Quick Reference · 速查示例
bash

实时查看 ERROR 日志并高亮
tail -f app.log | grep --color=always ERROR

统计今天每种级别的日志数量
grep "^2025-03-15" app.log | awk '{count[$3]++} END {for(k in count) print k, count[k]}'

查看最近10次 Full GC
grep "Full GC" gc.log | tail -10

找出访问量最大的前5个 IP
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -5

手动执行日志切割
sudo logrotate -f /etc/logrotate.d/myapp

搜索压缩日志
zgrep "ERROR" app.log.gz

提取所有异常堆栈的第一行
grep -A 1 "Exception" app.log | grep -v "^--$"

---

## 📜 Script Demo · 示例脚本

See [`demo.sh`](./demo.sh) for a runnable script demonstrating these techniques in action.

---

## 🇨🇳 中文说明

本目录整理了日志分析的实用技巧，涵盖实时监控、搜索过滤、字段提取、聚合统计、日志切割和常见分析场景。每个技巧都配有中英文说明和示例。  
建议结合实际项目日志多加练习，熟能生巧。

---

*Logs are the eyes of your application.* 👁️