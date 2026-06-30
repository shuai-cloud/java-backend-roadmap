# JVM Troubleshooting Guide 🔍

> 针对 Java 后端应用的 Linux 层 + JVM 层联合排障手册  
> Combined Linux and JVM troubleshooting guide for Java backend engineers.

---

## 📖 Overview · 概述

When a Java application behaves abnormally (slow response, high CPU, OOM, hang), you need to diagnose from two layers:

1. **OS level** (Linux) – identify resource bottlenecks (CPU, memory, disk, network).
2. **JVM level** – inspect heap, threads, GC behavior.

This document focuses on the **JVM-specific tools** (`jstack`, `jmap`, `jstat`, `jcmd`) and how to use them alongside Linux commands.

当 Java 应用出现异常（响应慢、CPU 高、内存溢出、卡死）时，需要从操作系统和 JVM 两个层面排查。本文聚焦于 JVM 专用工具及其与 Linux 命令的结合使用。

---

## 🛠️ Prerequisites · 前置条件

- JDK 8+ installed (tools are in `$JAVA_HOME/bin/`).
- The target Java process must be running with the same JDK version.
- For containerized environments, ensure `jattach` or `jcmd` is available.

---

## 🔥 Scenario 1: High CPU Usage · CPU 飙高

### Symptoms
- `top` shows a Java process using >100% CPU.
- Application becomes sluggish.

### Steps

#### Step 1: Find the Java PID

bash

top -c   # press 'P' to sort by CPU

or

ps aux --sort=-%cpu | grep java | head -5

#### Step 2: Identify the Hottest Thread

bash

top -H -p <PID>   # show threads inside the process

Note the thread ID (decimal) of the highest CPU consumer.

#### Step 3: Convert Thread ID to Hex

bash

printf "%x\n" <thread_id>

#### Step 4: Dump Thread Stack with jstack

bash

jstack <PID> > /tmp/threaddump.txt

Search for the hex thread ID in the dump:

bash

grep -A 20 "nid=0x<hex_id>" /tmp/threaddump.txt

#### Step 5: Analyze the Stack
Look for:
- Infinite loops or busy wait.
- Garbage collection threads (`GC task thread`).
- Lock contention (BLOCKED state).

#### Example Output

"http-nio-8080-exec-10" #30 daemon prio=5 os_prio=0 tid=0x00007f...

java.lang.Thread.State: RUNNABLE

at com.example.service.MyService.process(MyService.java:45)

...

If the stack repeatedly hits your own code, review that logic.  
If it's in a native method (e.g., `java.zip.ZipFile.getEntry`), check file I/O.

---

## 💥 Scenario 2: OutOfMemoryError (OOM) · 内存溢出

### Symptoms
- Application crashes with `java.lang.OutOfMemoryError`.
- Heap dump may be generated if `-XX:+HeapDumpOnOutOfMemoryError` is set.

### Steps

#### Step 1: Check OS Memory

bash

free -h

cat /proc/meminfo | grep MemAvailable

#### Step 2: Get JVM Heap Summary with jmap

bash

jmap -heap <PID>

Look for:
- `Eden Space`, `Survivor Space`, `Old Generation` usage.
- `Metaspace` usage (common for classloader leaks).

#### Step 3: Take a Heap Dump (if not already generated)

bash

jmap -dump:live,format=b,file=/tmp/heap.hprof <PID>

> ⚠️ This pauses the JVM briefly. Use `jcmd <PID> GC.heap_dump /tmp/heap.hprof` for a safer alternative.

#### Step 4: Analyze the Heap Dump
Use tools like:
- **Eclipse MAT** (Memory Analyzer Tool) – find leak suspects.
- **VisualVM** – browse objects.
- **JProfiler** (commercial).

Common causes:
- Static collections growing indefinitely (cache without eviction).
- ThreadLocal not cleaned up.
- Large third-party data loaded into memory.

#### Step 5: Enable GC Logging for Next Occurrence
Add to JVM args:

-XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:/tmp/gc.log

---

## 🐢 Scenario 3: Frequent GC / Long GC Pauses · GC 频繁

### Symptoms
- Application experiences periodic latency spikes.
- Throughput drops.

### Steps

#### Step 1: Monitor GC Statistics with jstat
bash

jstat -gcutil <PID> 1000 10   # print every 1 second, 10 times

Output columns:
- `S0/S1` – survivor space usage (%).
- `E` – Eden usage (%).
- `O` – Old generation usage (%).
- `M` – Metaspace usage (%).
- `YGC/YGCT` – Young GC count/time.
- `FGC/FGCT` – Full GC count/time.

**Red flags**:
- `O` approaching 100% → likely full GC imminent.
- `FGCT` increasing rapidly → stop-the-world pauses.

#### Step 2: Inspect GC Algorithm and Arguments
bash

jcmd <PID> VM.flags | grep -i gc

#### Step 3: Correlate with Linux Metrics
bash

sar -u 1 5   # CPU usage

sar -r 1 5   # memory usage

If CPU is low but GC time is high, the problem is often insufficient heap size or wrong GC policy.

#### Step 4: Adjust JVM Parameters
Common optimizations:
- Increase heap: `-Xms4g -Xmx4g`
- Choose appropriate GC: `-XX:+UseG1GC` (default since JDK 9) or `-XX:+UseParallelGC`.
- Set ratio: `-XX:NewRatio=2` (young:old = 1:2).
- Limit GC threads: `-XX:ParallelGCThreads=4`.

---

## 🔒 Scenario 4: Application Hang / Deadlock · 应用卡死

### Symptoms
- No response to requests.
- Thread dumps show many BLOCKED threads.

### Steps

#### Step 1: Take Multiple Thread Dumps
bash

for i in {1..5}; do jstack <PID> >> /tmp/threaddump_$(date +%H%M%S).txt; sleep 2; done

#### Step 2: Search for Deadlocks
jstack automatically prints deadlock info at the end of the dump:

Found one Java-level deadlock:

"Thread-1":

waiting to lock <0x...> which is held by "Thread-0"

"Thread-0":

waiting to lock <0x...> which is held by "Thread-1"

#### Step 3: Identify Contended Locks
Use `jcmd <PID> Thread.print -l` to list locked monitors.

Or analyze with `fastthread.io` (upload thread dumps online).

#### Step 4: Fix the Code
- Reduce synchronized scope.
- Use `ReentrantLock` with tryLock(timeout).
- Avoid nested locks with different ordering.

---

## 📊 Quick Reference · 速查表

| Tool | Purpose | Example |
|------|---------|---------|
| `jstack` | Print thread dump | `jstack <PID>` |
| `jmap -heap` | Heap summary | `jmap -heap <PID>` |
| `jmap -histo:live` | Live object histogram | `jmap -histo:live <PID> \| head -20` |
| `jstat -gcutil` | GC statistics | `jstat -gcutil <PID> 1s` |
| `jcmd` | Multipurpose diagnostic | `jcmd <PID> help` |
| `jinfo` | JVM configuration | `jinfo -flags <PID>` |
| `jvisualvm` | GUI monitoring (local only) | `jvisualvm &` |

---

## 🧪 Practice Exercise · 练习

1. Start any Java application (e.g., Spring Boot jar).
2. Simulate high CPU: create a busy loop in your code.
3. Use `top`, `jstack`, and `jstat` to locate the problematic thread.
4. Simulate OOM: allocate large arrays in a loop.
5. Capture heap dump and analyze with MAT.

---

## 🇨🇳 中文小结

| 场景 | 关键命令 | 排查思路 |
|------|----------|----------|
| CPU 高 | `top -H` + `jstack` | 找线程ID → 转换十六进制 → 查看栈 |
| OOM | `jmap -heap` + `jmap -dump` | 看老年代使用率 → 导出堆 → MAT 分析 |
| GC 频繁 | `jstat -gcutil` | 观察 YGC/FGC 频率和时间 → 调整参数 |
| 死锁 | `jstack` 多次 | 搜索 deadlock 字样 → 检查锁顺序 |

---

*Remember: Always start with Linux tools (`top`, `free`, `iostat`) before diving into JVM specifics.*  
*记住：先看操作系统层面，再深入 JVM 内部。*