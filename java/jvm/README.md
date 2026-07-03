# JVM 🖥️

> Java Virtual Machine internals for backend engineers (3–5 years experience).  
> JVM 内部原理核心知识，面试必考。

[![Java](https://img.shields.io/badge/Java-17%2B-orange)](https://openjdk.org/)

---

## 📖 Overview · 概览

This section covers JVM internals: memory model, garbage collection, class loading, bytecode, performance tuning, and common troubleshooting. Understanding JVM is essential for diagnosing OOM, high CPU, and latency issues in production. Each topic includes code examples with Chinese comments and common interview questions with answers.

本章涵盖 JVM 内部原理：内存模型、垃圾回收、类加载、字节码、性能调优和常见问题排查。理解 JVM 对于诊断生产环境中的 OOM、CPU 飙高和延迟问题至关重要。每个主题都包含带中文注释的代码示例和带答案的常见面试题。

---

## 🗂️ Topics · 主题速查

### 1️⃣ JVM Memory Model · JVM 内存模型
┌─────────────────────────────────────┐

│  Thread Stack (每个线程私有)          │

│  ├── Program Counter Register       │

│  ├── Java Stack (局部变量、操作数栈)   │

│  └── Native Method Stack            │

├─────────────────────────────────────┤

│  Heap (所有线程共享)                  │

│  ├── Young Generation               │

│  │   ├── Eden Space                 │

│  │   └── Survivor Spaces (S0, S1)   │

│  └── Old Generation                 │

├─────────────────────────────────────┤

│  Metaspace (JDK 8+，取代永久代)       │

│  └── Class metadata, constants       │

├─────────────────────────────────────┤

│  Direct Memory (堆外内存)            │

└─────────────────────────────────────┘

**参数设置**：

| Parameter | Description · 说明 |
|-----------|--------------------|
| `-Xms` | Initial heap size · 初始堆大小 |
| `-Xmx` | Maximum heap size · 最大堆大小 |
| `-Xmn` | Young generation size · 年轻代大小 |
| `-XX:MetaspaceSize` | Initial metaspace size · 元空间初始大小 |
| `-XX:MaxMetaspaceSize` | Maximum metaspace size · 元空间最大大小 |
| `-Xss` | Thread stack size · 线程栈大小 |
| `-XX:SurvivorRatio` | Eden : Survivor ratio (default 8) · Eden 与 Survivor 比例 |
| `-XX:+UseCompressedOops` | Compress object pointers · 压缩对象指针 |

---

### 2️⃣ Garbage Collection · 垃圾回收

#### GC Algorithm · 垃圾回收算法

| Algorithm | Description · 说明 | Pros & Cons |
|-----------|--------------------|-------------|
| Mark-Sweep | 标记存活对象，清除未标记对象 | 产生碎片，效率随对象增多下降 |
| Copying | 将存活对象复制到另一区域，清空原区域 | 无碎片，但浪费一半空间 |
| Mark-Compact | 标记存活对象，向一端移动，清除边界外 | 无碎片，但移动对象开销大 |

#### Garbage Collectors · 垃圾回收器

| Collector | Region | Algorithm | Features |
|-----------|--------|-----------|----------|
| Serial | Young | Copying | 单线程，暂停所有应用线程（Stop-The-World） |
| ParNew | Young | Copying | Serial 的多线程版本 |
| Parallel Scavenge | Young | Copying | 关注吞吐量，可控制暂停时间 |
| Serial Old | Old | Mark-Compact | Serial 的老年代版本 |
| Parallel Old | Old | Mark-Compact | Parallel 的老年代版本 |
| CMS | Old | Mark-Sweep | 低延迟，并发收集，产生碎片 |
| G1 | Young+Old | Region-based | 可预测停顿，JDK 9+ 默认 |
| ZGC | All | Region-based | 超低延迟 (<10ms)，JDK 15+ 正式版 |

**常用 GC 参数**：
bash

查看当前 JVM 使用的 GC
java -XX:+PrintFlagsFinal -version | grep "Use.*GC"

指定 GC
-XX:+UseG1GC

-XX:+UseConcMarkSweepGC

-XX:+UseParallelGC

GC 日志
-XX:+PrintGCDetails

-XX:+PrintGCDateStamps

-Xloggc:/path/to/gc.log

---

### 3️⃣ Class Loading · 类加载

#### Class Loading Process · 类加载过程
Loading → Verification → Preparation → Resolution → Initialization

↓                                                          ↓

通过全限定名获取二进制字节流                            执行 <clinit>() 方法

验证字节码合法性                                        静态变量赋值

分配静态变量内存并赋默认值                               静态代码块执行

将符号引用替换为直接引用（可选）

#### Class Loaders · 类加载器
Bootstrap ClassLoader (C++ 实现)

↓

Extension ClassLoader (加载 jre/lib/ext)

↓

Application ClassLoader (加载 classpath)

↓

Custom ClassLoader (用户自定义)

**双亲委派模型**：
- 当一个类加载器收到加载请求时，先将请求委托给父加载器。
- 只有当父加载器无法加载时，子加载器才尝试自己加载。
- 优点：保证核心类库的安全性（如 `java.lang.String` 不会被篡改）。

**打破双亲委派的场景**：
- Tomcat：每个 Web 应用有自己的 ClassLoader，优先加载自己 `WEB-INF/lib` 下的类。
- SPI（Service Provider Interface）：`ServiceLoader` 使用线程上下文类加载器加载第三方实现。

---

### 4️⃣ Bytecode & JIT · 字节码与即时编译
java

// 简单的 Java 方法

public int add(int a, int b) {

return a + b;

}

// 对应的字节码（javap -c 查看）

// 0: iload_1

// 1: iload_2

// 2: iadd

// 3: ireturn

**JIT 编译器**：
- Client Compiler (C1)：快速编译，优化较少，适合桌面应用。
- Server Compiler (C2)：慢速编译，激进优化，适合服务端。
- Tiered Compilation (分层编译)：先 C1 编译，热点代码再 C2 编译（JDK 8 默认）。

**常见优化技术**：
- 方法内联（Inlining）
- 逃逸分析（Escape Analysis）：栈上分配、锁消除、标量替换
- 循环优化（Loop unrolling, Loop fusion）
- 死代码消除

---

### 5️⃣ JVM Tuning · JVM 调优

#### 常用调优参数
bash

堆设置
-Xms4g -Xmx4g -Xmn2g -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=256m

GC 选择
-XX:+UseG1GC -XX:MaxGCPauseMillis=200

GC 日志
-Xloggc:/var/log/gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintTenuringDistribution

OOM 时自动 dump
-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/log/heapdump.hprof

其他
-XX:+DisableExplicitGC        # 禁止 System.gc()

-Djava.awt.headless=true       # 无头模式（服务器环境）

#### 调优步骤

1. **确定目标**：吞吐量优先还是低延迟优先？
2. **监控现状**：使用 `jstat`、`jmap`、`jstack`、VisualVM 等工具。
3. **调整参数**：从堆大小和 GC 选择开始。
4. **验证效果**：对比调优前后的 GC 日志和性能指标。

---

### 6️⃣ Troubleshooting · 问题排查

#### OOM 排查
bash

1. 查看堆使用情况
   jstat -gcutil <PID> 1000 10

2. 查看堆直方图（哪些对象占用了最多内存）
   jmap -histo:live <PID> | head -20

3. 导出堆转储
   jmap -dump:live,format=b,file=/tmp/heap.hprof <PID>

4. 使用 MAT 或 VisualVM 分析堆转储

#### CPU 飙高排查
bash

1. 找到 CPU 最高的进程
   top -c

2. 找到进程内 CPU 最高的线程
   top -H -p <PID>

3. 将线程 ID 转为十六进制
   printf "%x\n" <TID>

4. 查看线程栈
   jstack <PID> | grep -A 30 "nid=0x<hex>"

#### 死锁排查
bash

使用 jstack 查看死锁
jstack -l <PID> | grep -A 30 "deadlock"

或者使用 jconsole 图形界面
---

## 📂 Code Examples · 代码示例

All runnable code examples are located in the [`src/`](./src/) directory:

| File | Description |
|------|-------------|
| `MemoryModelDemo.java` | 演示堆、栈、元空间的使用 |
| `GCLogAnalysis.java` | 生成 GC 日志并分析 |
| `ClassLoaderDemo.java` | 自定义类加载器 |
| `OOMDemo.java` | 模拟堆溢出、栈溢出、元空间溢出 |
| `DeadlockDemo.java` | 制造死锁并排查 |

---

## ❓ Interview Questions with Answers · 面试题（附答案）

### 内存模型
1. **JVM 内存区域有哪些？哪些是线程私有的？**
    - **答**：堆（所有线程共享）、元空间（共享）、虚拟机栈（私有）、本地方法栈（私有）、程序计数器（私有）。栈和程序计数器是线程私有的。

2. **JDK 8 为什么用元空间替代永久代？**
    - **答**：永久代大小固定，容易 OOM；元空间使用本地内存，默认无上限，减少 OOM 风险。同时，将字符串常量池和静态变量移到了堆中。

### 垃圾回收
3. **如何判断对象是否可回收？**
    - **答**：可达性分析。从 GC Roots（栈帧引用、静态属性、JNI 引用等）出发，不可达的对象可回收。另外，软引用、弱引用、虚引用也有不同回收时机。

4. **CMS 和 G1 的区别？**
    - **答**：CMS 并发收集老年代，标记-清除，产生碎片，无法处理浮动垃圾；G1 将堆划分为 Region，可预测停顿，JDK 9+ 默认。G1 能更好地控制 GC 暂停时间。

5. **GC 调优的目标是什么？**
    - **答**：通常有两个目标：① 减小 STW 暂停时间；② 提高吞吐量。两者往往矛盾，需要根据应用场景权衡。

### 类加载
6. **双亲委派模型的作用？**
    - **答**：保证核心类库的安全性（如 `java.lang.String` 不会被用户自定义类替换），避免类的重复加载。

7. **如何打破双亲委派模型？**
    - **答**：自定义 ClassLoader 重写 `loadClass()` 方法，不委托父加载器。Tomcat 的 WebAppClassLoader 就是典型例子。

### 字节码与 JIT
8. **什么是逃逸分析？有什么优化？**
    - **答**：逃逸分析判断对象是否逃逸出方法或线程。如果对象不逃逸，可以进行栈上分配（减少 GC 压力）、锁消除（去掉不必要的同步）、标量替换（将对象拆分为基本类型）。

### 调优与排查
9. **JVM 调优常用的参数有哪些？**
    - **答**：`-Xms`、`-Xmx`、`-Xmn`、`-XX:MetaspaceSize`、`-XX:+UseG1GC`、`-XX:MaxGCPauseMillis`、`-XX:+HeapDumpOnOutOfMemoryError`、`-Xloggc` 等。

10. **线上 CPU 飙高如何排查？**
    - **答**：top 找到进程 → top -H 找到线程 → printf "%x\n" 转十六进制 → jstack 查看线程栈 → 定位问题代码。

11. **OOM 如何排查？**
    - **答**：添加 `-XX:+HeapDumpOnOutOfMemoryError` 参数，OOM 时自动 dump。然后用 MAT 分析堆转储，查看 GC Roots 和 Leak Suspect。

---

## 🇨🇳 中文说明

本目录覆盖了 JVM 的核心知识，包括内存模型、垃圾回收、类加载、字节码、JIT 编译、性能调优和问题排查。每个主题都配有带中文注释的代码示例和带答案的面试题。代码示例在 `src/` 目录下，可以直接编译运行。

---

*Know your JVM, master your application.* 🖥️