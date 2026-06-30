# Process 🧵

> Linux process management for Java backend engineers.  
> Java 后端工程师必备的进程管理知识。

---

## 📖 Overview · 概览

This section covers Linux process viewing, controlling, and troubleshooting. As a Java backend engineer, you'll frequently need to identify runaway processes, send signals, manage background jobs, and analyze resource usage. Understanding process states and signals is also crucial for debugging application hangs and crashes.

本章涵盖 Linux 进程的查看、控制和排障。作为 Java 后端工程师，你经常需要识别失控进程、发送信号、管理后台作业以及分析资源使用。理解进程状态和信号对于调试应用卡死和崩溃也至关重要。

---

## 🗂️ Commands · 命令速查

### 1️⃣ Viewing Processes · 查看进程

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `ps` | Snapshot of current processes · 当前进程快照 | `aux` 显示所有进程（BSD风格）；`-ef` 显示所有进程（标准风格）；`-eo pid,ppid,%cpu,%mem,cmd` 自定义输出列；`--sort=-%cpu` 按CPU降序 |
| `top` | Interactive process viewer · 交互式进程查看器 | 按 `P` 按CPU排序；按 `M` 按内存排序；按 `k` 杀死进程；按 `q` 退出；`-u username` 只看某用户；`-p PID` 只看某进程 |
| `htop` | Enhanced interactive process viewer · 增强版交互进程查看器（需安装） | 颜色更友好，支持鼠标操作，F5 树状视图，F6 排序 |
| `pgrep` | Look up processes by name · 按名称查找进程 PID | `-u username` 限定用户；`-f` 匹配完整命令行；`-l` 同时显示进程名；`-a` 显示完整命令行 |
| `pstree` | Display processes as a tree · 以树形显示进程关系 | `-p` 显示 PID；`-u` 显示用户切换；`-a` 显示命令行参数 |

**注意事项**：
- `ps aux` 是最常用的进程查看命令，输出包括 USER、PID、%CPU、%MEM、VSZ、RSS、TTY、STAT、START、TIME、COMMAND。
- `top` 是实时刷新，适合持续监控；`htop` 体验更好，但需安装。
- `pgrep` 常用于脚本中获取 PID。

---

### 2️⃣ Process States · 进程状态

| State | Meaning · 含义 |
|-------|----------------|
| R | Running or runnable (on run queue) · 正在运行或可运行 |
| S | Interruptible sleep (waiting for event) · 可中断睡眠（等待事件） |
| D | Uninterruptible sleep (usually I/O) · 不可中断睡眠（通常是I/O） |
| T | Stopped (by signal or trace) · 已停止（被信号或跟踪暂停） |
| Z | Zombie (defunct, parent hasn't reaped) · 僵尸进程（已终止但父进程未回收） |
| X | Dead (should never be seen) · 死亡（几乎看不到） |
| < | High-priority (not nice to others) · 高优先级 |
| N | Low-priority (nice to others) · 低优先级 |
| s | Session leader · 会话领导者 |
| l | Multi-threaded (clone threads) · 多线程 |

**注意事项**：
- 僵尸进程无法被杀死，只能通过杀掉其父进程来清理。
- D 状态进程不能被信号打断，通常表示磁盘 I/O 阻塞。

---

### 3️⃣ Controlling Processes · 控制进程

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `kill` | Send a signal to a process · 向进程发送信号 | `-9` SIGKILL（强制杀死）；`-15` SIGTERM（优雅终止，默认）；`-2` SIGINT（Ctrl+C）；`-1` SIGHUP（重新加载配置）；`-3` SIGQUIT（生成线程dump） |
| `pkill` | Kill processes by name · 按名称杀死进程 | `-f` 匹配完整命令行；`-u username` 限定用户；`-9` 强制杀死 |
| `killall` | Kill processes by exact name · 按精确名称杀死所有同名进程 | `-9` 强制；`-i` 交互确认；`-r` 正则匹配 |

**注意事项**：
- 优先使用 `kill -15`（SIGTERM）让进程自行清理，不行再用 `kill -9`。
- 对 Java 进程使用 `kill -3` 会触发线程 dump 到 stdout，常用于排查死锁。
- `pkill` 和 `killall` 慎用，可能误杀同名进程。

---

### 4️⃣ Process Priority · 进程优先级

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `nice` | Run a program with modified scheduling priority · 以调整后的优先级运行程序 | `-n -20` 最高优先级（值越小优先级越高）；`-n 19` 最低优先级；范围 -20 到 19 |
| `renice` | Alter priority of running processes · 修改运行中进程的优先级 | `-n -5 -p PID` 设置 PID 的 nice 值为 -5；`-u username` 修改某用户所有进程的优先级 |

**注意事项**：
- 普通用户只能降低优先级（增加 nice 值），只有 root 能提高优先级。
- 实时进程使用 `chrt` 命令，不在本节讨论范围。

---

### 5️⃣ Background Jobs · 后台作业

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `&` | Run command in background · 在后台运行命令 | `command &` |
| `nohup` | Run command immune to hangups · 使命令忽略挂断信号（关闭终端后继续运行） | `nohup command &`；输出默认写入 `nohup.out` |
| `jobs` | List active jobs · 列出当前 shell 的后台作业 | `-l` 显示 PID；`-p` 只显示 PID |
| `fg` | Bring a background job to foreground · 将后台作业调到前台 | `fg %1` 将作业1调到前台 |
| `bg` | Resume a stopped background job · 继续运行已停止的后台作业 | `bg %1` |
| `disown` | Remove a job from shell's job table · 从 shell 的作业表中移除（关闭终端后继续运行） | `disown %1`；`-h` 标记作业不被 SIGHUP 影响 |

**注意事项**：
- `nohup command &` 是后台运行 Java 应用的经典方式。
- `disown` 用于将已经在后台的作业脱离终端控制。

---

### 6️⃣ Process Resource Analysis · 进程资源分析

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `pidstat` | Report statistics for Linux tasks · 报告进程的 CPU、内存、I/O 统计（需 sysstat 包） | `-u` CPU 使用；`-r` 内存使用；`-d` I/O 统计；`-p PID` 指定进程；`1 5` 每秒采样，共5次 |
| `pmap` | Report memory map of a process · 报告进程的内存映射 | `-x` 扩展显示；`-d` 设备映射；`-q` 安静模式 |
| `lsof` | List open files · 列出打开的文件（一切皆文件） | `-i :8080` 查看占用 8080 端口的进程；`-u username` 查看某用户打开的文件；`-p PID` 查看某进程打开的文件；`+D /path` 递归查看目录中被打开的文件 |

**注意事项**：
- `lsof -i :port` 是排查端口冲突的利器。
- `pmap -x PID` 可以查看 Java 进程的堆、栈、共享库等内存分布。

---

## 🚀 Quick Reference · 速查示例

bash

查看所有 Java 进程

ps aux | grep java

按 CPU 使用率排序查看前 10 个进程

ps aux --sort=-%cpu | head -10

实时监控进程

top -u appuser

查找名为 nginx 的进程 PID

pgrep -l nginx

优雅停止 Java 进程

kill -15 <PID>

强制杀死进程

kill -9 <PID>

后台运行 Spring Boot 应用

nohup java -jar app.jar > app.log 2>&1 &

查看 8080 端口被哪个进程占用

lsof -i :8080

查看进程的内存映射

pmap -x <PID>

修改进程优先级为最低

renice -n 19 -p <PID>

---

## 📜 Script Demo · 示例脚本

See [`demo.sh`](./demo.sh) for a runnable script demonstrating these commands in action.

---

## 🇨🇳 中文说明

本目录整理了 Linux 进程管理相关的常用命令，涵盖进程查看、状态理解、信号控制、后台作业和资源分析。每个命令都提供了中英文用途说明和常用选项的中文解释。  
建议结合 Java 应用的实际运行场景练习，例如用 `kill -3` 获取线程 dump，用 `lsof` 排查端口冲突。

---

*Know your processes, master your server.* ⚙️