# Performance 📊

> Linux performance monitoring and tuning for Java backend engineers.  
> Java 后端工程师必备的性能监控与调优知识。

---

## 📖 Overview · 概览

This section covers Linux performance monitoring tools and techniques. As a Java backend engineer, you'll frequently need to identify CPU spikes, memory leaks, disk I/O bottlenecks, and network saturation. Understanding these tools helps you quickly pinpoint root causes during incidents.

本章涵盖 Linux 性能监控工具和技巧。作为 Java 后端工程师，你经常需要定位 CPU 飙高、内存泄漏、磁盘 I/O 瓶颈和网络饱和等问题。掌握这些工具能帮助你在事故发生时快速定位根因。

---

## 🗂️ Commands · 命令速查

### 1️⃣ CPU Performance · CPU 性能

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `top` | Real-time process overview · 实时进程概览 | `-u user` 只看某用户；`-p PID` 只看某进程；按 `1` 显示每个 CPU 核心；按 `P` 按 CPU 排序 |
| `htop` | Enhanced top (colorful, mouse support) · 增强版 top | 需安装；F5 树状视图；F6 排序；F9 杀进程 |
| `mpstat` | Per-CPU statistics · 每个 CPU 核心的统计 | `-P ALL` 显示所有核心；`1 5` 每秒采样，共5次 |
| `pidstat -u` | Per-process CPU usage · 每个进程的 CPU 使用 | `-p PID` 指定进程；`1 5` 每秒采样；`-t` 显示线程 |
| `perf` | Advanced profiling · 高级性能剖析 | `top` 实时热点；`record` + `report` 采样分析；`stat` 统计计数器 |

**注意事项**：
- CPU 使用率高不等于有问题，需要结合上下文（用户态/内核态/等待 I/O）。
- `mpstat` 可以看到某个 CPU 核心是否被独占（如绑核的 Java 线程）。

---

### 2️⃣ Memory Performance · 内存性能

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `free` | Display memory usage · 显示内存使用 | `-h` 人类可读；`-m` MB 单位；`-s 2` 每2秒刷新 |
| `vmstat` | Virtual memory statistics · 虚拟内存统计 | `1 5` 每秒采样，共5次；重点关注 `si`（swap in）和 `so`（swap out） |
| `smem` | Memory reporting per process (RSS/PSS/USS) · 每个进程的内存报告 | `-p` 按比例显示；`-s rss` 按 RSS 排序；`-t` 显示总计 |
| `/proc/meminfo` | Detailed memory info · 详细内存信息 | `cat /proc/meminfo`；关注 MemAvailable、Buffers、Cached、SwapTotal |

**注意事项**：
- `free -h` 中的 `available` 列才是真正可用的内存（包括可回收的缓存）。
- 大量 swap 使用（`si`/`so` 非零）通常意味着物理内存不足。
- Java 进程的 RSS 包括堆、栈、元空间、JIT 代码等。

---

### 3️⃣ Disk I/O Performance · 磁盘 I/O 性能

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `iostat` | CPU and I/O statistics · CPU 和 I/O 统计 | `-x` 扩展显示（含 await, svctm, %util）；`-d` 只显示磁盘；`1 5` 每秒采样 |
| `iotop` | Per-process I/O usage · 每个进程的 I/O 使用 | `-o` 只显示有 I/O 的进程；`-P` 只显示进程（不显示线程） |
| `sar -d` | Historical I/O statistics · 历史 I/O 统计 | `-d` 磁盘活动；`-p` 显示设备名；`1 5` |

**关键指标**：
- `%util`：磁盘繁忙百分比（接近 100% 表示饱和）。
- `await`：I/O 请求平均等待时间（毫秒），过高表示磁盘性能瓶颈。
- `r/s`、`w/s`：每秒读写请求数。

---

### 4️⃣ Network Performance · 网络性能

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `sar -n` | Network statistics · 网络统计 | `DEV` 网络接口统计；`TCP` TCP 连接统计；`ETCP` TCP 错误统计；`1 5` |
| `iftop` | Bandwidth usage per connection · 每个连接的带宽使用 | `-i eth0` 指定网卡；`-n` 不解析主机名；`-P` 显示端口 |
| `nethogs` | Bandwidth per process · 每个进程的带宽使用 | `-d 2` 刷新间隔；`-v 0` 累计模式 |
| `nicstat` | Network interface utilization · 网络接口利用率 | `-i eth0` 指定网卡；`-z` 跳过空闲接口 |

**注意事项**：
- `sar -n DEV 1 3` 可以快速查看网卡吞吐量和包错误率。
- `iftop` 和 `nethogs` 需要 root 权限。

---

### 5️⃣ System Load · 系统负载

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `uptime` | System load averages · 系统平均负载 | 显示 1/5/15 分钟平均负载 |
| `sar -q` | Queue length and load · 队列长度和负载 | `-q` 运行队列大小和负载平均值；`1 5` |
| `dmesg` | Kernel ring buffer messages · 内核环形缓冲区消息 | `-T` 显示人类可读时间；`-l err` 只显示错误级别 |

**注意事项**：
- 平均负载高于 CPU 核心数通常表示有进程在等待 CPU（但不一定是坏事）。
- `dmesg` 中可能看到 OOM killer、软锁等关键信息。

---

### 6️⃣ Comprehensive Tools · 综合分析工具

| Tool | Description · 说明 | Installation |
|------|--------------------|--------------|
| `dstat` | Versatile resource statistics (combines vmstat/iostat/netstat) · 多功能资源统计 | `apt install dstat` / `yum install dstat` |
| `glances` | Cross-platform monitoring (web UI available) · 跨平台监控 | `pip install glances` / `apt install glances` |
| `atop` | Advanced system monitor with logging · 高级系统监控（带日志） | `apt install atop` / `yum install atop` |

---

## 🚀 Quick Reference · 速查示例
bash

快速查看系统瓶颈
top                     # CPU 和内存

free -h                 # 内存

iostat -x 1 3           # 磁盘 I/O

sar -n DEV 1 3          # 网络

定位 CPU 最高的线程
top -H -p <PID>         # 查看进程内线程

printf "%x\n" <tid>     # 转十六进制

jstack <PID> | grep -A 20 "nid=0x<hex>"  # 查看线程栈

查看磁盘 I/O 等待
iostat -x 1

查看内存详情
cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree"

使用 dstat 一键查看所有
dstat -tcyrdn 5

---

## 📜 Script Demo · 示例脚本

See [`demo.sh`](./demo.sh) for a runnable script demonstrating these commands in action.

---

## 🇨🇳 中文说明

本目录整理了 Linux 性能监控相关的命令，涵盖 CPU、内存、磁盘 I/O、网络、系统负载以及综合分析工具。每个命令都提供了中英文用途说明和常用选项的中文解释。  
建议结合线上问题场景练习，例如用 `top` 和 `jstack` 定位 Java 进程 CPU 高的问题。

---

*Measure before you tune. Observe before you act.* 📈