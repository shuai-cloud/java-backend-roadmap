# Troubleshooting 🔧

> Linux troubleshooting guide for Java backend engineers.  
> Java 后端工程师必备的线上问题排查指南。

---

## 📖 Overview · 概览

This section provides a structured approach to diagnosing common production issues. Instead of listing isolated commands, we organize them by real-world scenarios you'll encounter as a Java backend engineer: high CPU, memory leaks, disk full, port conflicts, network timeouts, and hung processes.

本章提供结构化的生产问题排查方法。不同于罗列孤立的命令，我们按照 Java 后端工程师实际遇到的场景来组织：CPU 飙高、内存泄漏、磁盘满、端口冲突、网络超时、进程挂起等。

---

## 🗂️ Scenarios · 场景速查

### 1️⃣ High CPU · CPU 飙高

**Symptoms**: Application slows down, `top` shows Java process using >100% CPU.

**Step-by-step**:

| Step | Command | Description · 说明 |
|------|---------|--------------------|
| 1 | `top -c` | Find the Java PID (press `P` to sort by CPU) · 找到 Java 进程 PID |
| 2 | `top -H -p <PID>` | Find the hottest thread ID within the process · 找到进程内 CPU 最高的线程 ID |
| 3 | `printf "%x\n" <TID>` | Convert decimal TID to hexadecimal · 将十进制线程 ID 转为十六进制 |
| 4 | `jstack <PID> \| grep -A 30 "nid=0x<hex>"` | Dump thread stack and locate the problematic code · 导出线程栈定位问题代码 |
| 5 | `perf top -p <PID>` | (Optional) See native/hot methods if jstack doesn't help · 如果 jstack 不够，看 native 层热点 |

**Common causes**:
- Infinite loop or busy wait in business code.
- Excessive GC (see next section).
- Blocking I/O in unexpected places.

---

### 2️⃣ OutOfMemoryError / Memory Leak · 内存溢出/泄漏

**Symptoms**: Application crashes with `java.lang.OutOfMemoryError`, swap usage increases.

**Step-by-step**:

| Step | Command | Description · 说明 |
|------|---------|--------------------|
| 1 | `free -h` | Check overall memory and swap usage · 检查整体内存和 swap 使用 |
| 2 | `jmap -heap <PID>` | View JVM heap summary (Eden, Survivor, Old Gen) · 查看 JVM 堆概要 |
| 3 | `jmap -histo:live <PID> \| head -20` | See top live objects by count/size · 查看存活对象最多的类 |
| 4 | `jmap -dump:live,format=b,file=/tmp/heap.hprof <PID>` | Take heap dump for offline analysis · 导出堆转储文件 |
| 5 | Analyze with Eclipse MAT or VisualVM | Find leak suspect (dominant path to GC roots) · 用 MAT 分析泄漏嫌疑 |

**Common causes**:
- Static collections growing unbounded.
- ThreadLocal not removed after request ends.
- Large data loaded into memory without pagination.

---

### 3️⃣ Disk Full · 磁盘空间满

**Symptoms**: Application fails to write logs, database errors, `df -h` shows 100%.

**Step-by-step**:

| Step | Command | Description · 说明 |
|------|---------|--------------------|
| 1 | `df -h` | Identify which partition is full · 找出哪个分区满了 |
| 2 | `du -sh /* 2>/dev/null \| sort -rh \| head -10` | Find largest directories at root level · 根目录下最大的目录 |
| 3 | `du -sh /var/log/* \| sort -rh \| head -10` | Check log directory specifically · 重点检查日志目录 |
| 4 | `lsof \| grep deleted` | Find files that are deleted but still held open by processes · 查找已被删除但仍被进程占用的文件 |
| 5 | `find / -type f -size +500M -exec ls -lh {} \; 2>/dev/null` | Find all files larger than 500MB · 查找所有大于 500MB 的大文件 |

**Solutions**:
- Rotate/compress old logs (`logrotate`).
- Clear temporary files (`/tmp`, `/var/tmp`).
- Increase disk or move data to another partition.

---

### 4️⃣ Port Conflict · 端口冲突

**Symptoms**: Application fails to start with "Address already in use".

**Step-by-step**:

| Step | Command | Description · 说明 |
|------|---------|--------------------|
| 1 | `ss -tlnp \| grep :8080` | Check which process is listening on port 8080 · 查看哪个进程在监听 8080 |
| 2 | `lsof -i :8080` | Alternative: list open files for port 8080 · 另一种方式查看端口占用 |
| 3 | Decide: kill the conflicting process or change your app's port | 决定：杀掉冲突进程或修改应用端口 |

**Quick fix**:

bash

Kill the process occupying port 8080

kill -15 $(lsof -t -i :8080)

---

### 5️⃣ Network Timeout / Connection Refused · 网络超时/连接拒绝

**Symptoms**: Application cannot connect to database, Redis, or other services.

**Step-by-step**:

| Step | Command | Description · 说明 |
|------|---------|--------------------|
| 1 | `ping <host>` | Check basic reachability · 检查基本可达性 |
| 2 | `telnet <host> <port>` or `nc -zv <host> <port>` | Check if specific port is open · 检查特定端口是否开放 |
| 3 | `curl -v http://<host>:<port>/path` | Test HTTP endpoint with verbose output · 用详细输出测试 HTTP 端点 |
| 4 | `traceroute -n <host>` | Check routing path for packet loss · 检查路由路径是否有丢包 |
| 5 | `ss -tn \| grep <host>` | Check existing connections to the host · 检查到目标主机的现有连接 |

---

### 6️⃣ Hung / Unresponsive Process · 进程挂起

**Symptoms**: Process is alive but not responding to requests, thread dumps show many BLOCKED threads.

**Step-by-step**:

| Step | Command | Description · 说明 |
|------|---------|--------------------|
| 1 | `jstack <PID> > /tmp/td1.txt; sleep 3; jstack <PID> > /tmp/td2.txt` | Take multiple thread dumps · 多次导出线程栈 |
| 2 | `diff /tmp/td1.txt /tmp/td2.txt` | Compare dumps to see if threads are stuck · 对比两次 dump 看线程是否卡住 |
| 3 | Search for "deadlock" in dump | Check if there's a Java-level deadlock · 检查是否有 Java 死锁 |
| 4 | `strace -p <PID> -c` | Count system calls to see what the process is doing · 统计系统调用看进程在做什么 |
| 5 | `cat /proc/<PID>/status` | Check process state (running, sleeping, etc.) · 检查进程状态 |

---

### 7️⃣ System Log Investigation · 系统日志排查

| Log Source | Command | Description · 说明 |
|------------|---------|--------------------|
| Kernel messages | `dmesg -T \| tail -50` | Recent kernel messages (OOM, hardware errors) · 最近内核消息 |
| System logs | `journalctl -xe` | Systemd journal with explanations · systemd 日志带解释 |
| Auth logs | `tail -100 /var/log/auth.log` or `journalctl -u sshd` | Login attempts, sudo usage · 登录尝试、sudo 使用 |
| Application logs | `tail -F /var/log/myapp/app.log` | Your application's own logs · 应用自身日志 |

---

## 🚀 Quick Reference · 速查示例

bash

CPU 飙高快速排查

top -c                          # 找 Java PID

top -H -p <PID>                 # 找最热的线程

printf "%x\n" <TID>             # 转十六进制

jstack <PID> | grep -A 30 "nid=0x<hex>"  # 看栈

OOM 快速排查

free -h                         # 看内存

jmap -heap <PID>                # 看堆

jmap -dump:live,format=b,file=/tmp/heap.hprof <PID>  # 导堆

磁盘满快速排查

df -h                           # 看分区

du -sh /var/log/* | sort -rh | head -5  # 看大目录

lsof | grep deleted             # 看已删未释放

端口冲突快速排查

ss -tlnp | grep :8080           # 看谁占端口

kill -15 $(lsof -t -i :8080)    # 杀掉占用进程

---

## 📜 Script Demo · 示例脚本

See [`demo.sh`](./demo.sh) for a runnable script simulating troubleshooting scenarios.

---

## 🇨🇳 中文说明

本目录整理了 Java 后端工程师最常见的线上问题排查场景，每个场景都提供了从现象到根因的逐步排查步骤和对应命令。建议在测试环境中模拟这些问题进行练习，熟能生巧。

---

*Stay calm and troubleshoot systematically.* 🔍