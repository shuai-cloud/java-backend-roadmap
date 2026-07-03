# Concurrency 🧵

> Java concurrency for backend engineers (3–5 years experience).  
> Java 并发编程核心知识，面试必考。

[![Java](https://img.shields.io/badge/Java-17%2B-orange)](https://openjdk.org/)

---

## 📖 Overview · 概览

This section covers Java concurrency: thread basics, synchronization, locks, atomic classes, thread pools, concurrent collections, and common patterns. Understanding concurrency is critical for building scalable, high-performance applications. Each topic includes code examples with Chinese comments and common interview questions with answers.

本章涵盖 Java 并发编程：线程基础、同步、锁、原子类、线程池、并发集合和常见模式。理解并发对于构建可扩展的高性能应用至关重要。每个主题都包含带中文注释的代码示例和带答案的常见面试题。

---

## 🗂️ Topics · 主题速查

### 1️⃣ Thread Basics · 线程基础
java

// 创建线程的两种方式

// 方式1：继承 Thread

class MyThread extends Thread {

@Override

public void run() {

System.out.println("Thread running: " + Thread.currentThread().getName());

}

}

new MyThread().start();

// 方式2：实现 Runnable（推荐，更灵活）

Runnable task = () -> System.out.println("Runnable running");

new Thread(task).start();

// 线程状态

// NEW -> RUNNABLE -> BLOCKED/WAITING/TIMED_WAITING -> TERMINATED

Thread.State[] states = Thread.State.values();

// 常用方法

Thread.sleep(1000);           // 休眠 1 秒

Thread.yield();               // 让出 CPU

thread.join();                // 等待线程结束

thread.interrupt();           // 中断线程

**注意事项**：
- 直接调用 `run()` 不会启动新线程，只是普通方法调用。
- 推荐使用 `Runnable` 或 `Callable`，避免继承限制。

---

### 2️⃣ Synchronization · 同步
java

// synchronized 关键字

public class Counter {

private int count = 0;

// 同步实例方法（锁的是 this）
public synchronized void increment() {
count++;
}

// 同步静态方法（锁的是 Class 对象）
public static synchronized void staticMethod() {}

// 同步代码块
public void incrementBlock() {
synchronized (this) {
count++;
}
}
}

// 可见性：volatile 关键字

private volatile boolean running = true;  // 保证可见性，禁止指令重排

**synchronized 原理**：
- 基于 Monitor 对象（管程），每个对象关联一个 Monitor。
- 字节码层面：`monitorenter` / `monitorexit` 指令。
- JDK 6 优化：偏向锁 → 轻量锁 → 重量锁（锁升级）。

---

### 3️⃣ Locks · 显式锁
java

import java.util.concurrent.locks.*;

// ReentrantLock（可重入锁）

Lock lock = new ReentrantLock();

lock.lock();

try {

// 临界区

} finally {

lock.unlock();  // 必须在 finally 中释放

}

// 读写锁（ReadWriteLock）

ReadWriteLock rwLock = new ReentrantReadWriteLock();

Lock readLock = rwLock.readLock();

Lock writeLock = rwLock.writeLock();

// 读锁可多个线程同时持有，写锁独占

readLock.lock();

try {

// 读操作

} finally {

readLock.unlock();

}

// Condition（条件变量）

Condition notEmpty = lock.newCondition();

Condition notFull = lock.newCondition();

// await() / signal() / signalAll()

**synchronized vs ReentrantLock**：

| Feature | synchronized | ReentrantLock |
|---------|--------------|---------------|
| 自动释放 | 是（退出同步块） | 否（必须 unlock） |
| 可中断 | 否 | lockInterruptibly() |
| 公平性 | 非公平 | 可设置公平 |
| 条件变量 | wait/notify | Condition |
| 性能 | JDK 6 后差距不大 | 略优（高竞争） |

---

### 4️⃣ Atomic Classes · 原子类
java

import java.util.concurrent.atomic.*;

AtomicInteger counter = new AtomicInteger(0);

counter.incrementAndGet();           // ++i

counter.getAndIncrement();           // i++

counter.addAndGet(5);                // i += 5

counter.compareAndSet(10, 20);       // CAS 操作

AtomicReference<String> ref = new AtomicReference<>("initial");

ref.compareAndSet("initial", "updated");

// LongAdder（高并发下性能优于 AtomicLong）

LongAdder adder = new LongAdder();

adder.increment();

adder.sum();

**CAS（Compare-And-Swap）原理**：
- 硬件层面的原子操作（如 `cmpxchg` 指令）。
- ABA 问题：使用 `AtomicStampedReference` 或 `AtomicMarkableReference` 解决。

---

### 5️⃣ Thread Pool · 线程池
java

import java.util.concurrent.*;

// 创建线程池

ExecutorService executor = Executors.newFixedThreadPool(10);  // 固定大小

ExecutorService cached = Executors.newCachedThreadPool();     // 动态伸缩

ScheduledExecutorService scheduled = Executors.newScheduledThreadPool(5);

// 提交任务

Future<String> future = executor.submit(() -> {

Thread.sleep(1000);

return "Result";

});

String result = future.get();  // 阻塞等待结果

// 关闭

executor.shutdown();            // 不再接受新任务，等待已提交任务完成

executor.shutdownNow();         // 尝试停止所有正在执行的任务

**ThreadPoolExecutor 核心参数**：
java

ThreadPoolExecutor executor = new ThreadPoolExecutor(

corePoolSize,      // 核心线程数

maximumPoolSize,   // 最大线程数

keepAliveTime,     // 空闲线程存活时间

TimeUnit.SECONDS,

workQueue,         // 阻塞队列（如 LinkedBlockingQueue, ArrayBlockingQueue）

threadFactory,     // 线程工厂

rejectionHandler   // 拒绝策略

);

**拒绝策略**：
- `AbortPolicy`：抛出 RejectedExecutionException（默认）
- `CallerRunsPolicy`：调用者线程执行
- `DiscardPolicy`：静默丢弃
- `DiscardOldestPolicy`：丢弃队列中最旧的任务

---

### 6️⃣ Concurrent Collections · 并发集合

| Collection | Description · 说明 |
|------------|--------------------|
| ConcurrentHashMap | 高并发 HashMap |
| CopyOnWriteArrayList | 读多写少的 ArrayList |
| ConcurrentLinkedQueue | 高效无锁队列 |
| LinkedBlockingQueue | 阻塞队列（常用于线程池） |
| ArrayBlockingQueue | 有界阻塞队列 |
| DelayQueue | 延迟队列 |

---

### 7️⃣ AQS (AbstractQueuedSynchronizer) · 抽象队列同步器

AQS 是 JUC 锁和同步器的基础框架，内部维护：
- `volatile int state`：同步状态
- `CLH 队列`：等待线程的双向队列

**基于 AQS 实现的同步器**：
- `ReentrantLock`
- `Semaphore`
- `CountDownLatch`
- `ReentrantReadWriteLock`
- `CyclicBarrier`（基于 ReentrantLock 和 Condition）
  java

// CountDownLatch 示例

CountDownLatch latch = new CountDownLatch(3);

// 主线程等待

latch.await();

// 其他线程完成任务后调用 latch.countDown();

// Semaphore 示例

Semaphore semaphore = new Semaphore(5);  // 允许 5 个线程同时访问

semaphore.acquire();

// 访问资源

semaphore.release();

---

### 8️⃣ ThreadLocal · 线程局部变量
java

ThreadLocal<String> threadLocal = new ThreadLocal<>();

threadLocal.set("value");

String value = threadLocal.get();

threadLocal.remove();  // 使用后务必 remove，避免内存泄漏

// 使用场景：数据库连接、Session 信息、请求上下文

**注意事项**：
- ThreadLocal 的 key 是弱引用（WeakReference），但 value 是强引用。
- 线程池中线程复用，如果不 remove，可能导致内存泄漏或数据错乱。

---

## 📂 Code Examples · 代码示例

All runnable code examples are located in the [`src/`](./src/) directory:

| File | Description |
|------|-------------|
| `ThreadBasicsDemo.java` | 创建线程、线程状态、join |
| `SynchronizedDemo.java` | synchronized 用法、锁升级 |
| `LockDemo.java` | ReentrantLock, ReadWriteLock, Condition |
| `AtomicDemo.java` | AtomicInteger, CAS, LongAdder |
| `ThreadPoolDemo.java` | 线程池创建、提交、关闭 |
| `AQSExample.java` | CountDownLatch, Semaphore |
| `ThreadLocalDemo.java` | ThreadLocal 使用和注意事项 |

---

## ❓ Interview Questions with Answers · 面试题（附答案）

### 线程基础
1. **创建线程的方式有哪些？哪种推荐？**
    - **答**：继承 Thread、实现 Runnable、实现 Callable（配合 FutureTask）、线程池。推荐实现 Runnable 或 Callable，因为 Java 是单继承，实现接口更灵活。

2. **线程的状态有哪些？**
    - **答**：NEW（新建）、RUNNABLE（可运行）、BLOCKED（阻塞，等待锁）、WAITING（等待，无时限）、TIMED_WAITING（超时等待）、TERMINATED（终止）。

3. **sleep() 和 wait() 的区别？**
    - **答**：sleep() 是 Thread 的静态方法，不释放锁；wait() 是 Object 的方法，释放锁并进入等待队列，需要 notify/notifyAll 唤醒。

### 同步
4. **synchronized 的底层实现？**
    - **答**：基于 Monitor 对象，字节码使用 monitorenter/monitorexit 指令。JDK 6 后引入锁升级：偏向锁 → 轻量锁（CAS 自旋）→ 重量锁（操作系统互斥量）。

5. **volatile 关键字的作用？**
    - **答**：保证可见性（写操作立即刷新到主内存，读操作从主内存读取）和禁止指令重排（内存屏障）。但不保证原子性。

6. **synchronized 和 ReentrantLock 的区别？**
    - **答**：synchronized 自动释放锁，ReentrantLock 需要手动 unlock；ReentrantLock 支持可中断、公平锁、Condition；JDK 6 后两者性能接近。

### 线程池
7. **线程池的参数有哪些？**
    - **答**：corePoolSize（核心线程数）、maximumPoolSize（最大线程数）、keepAliveTime（空闲存活时间）、workQueue（阻塞队列）、threadFactory（线程工厂）、rejectionHandler（拒绝策略）。

8. **线程池的拒绝策略有哪些？**
    - **答**：AbortPolicy（抛异常）、CallerRunsPolicy（调用者线程执行）、DiscardPolicy（丢弃）、DiscardOldestPolicy（丢弃队列最旧任务）。

9. **如何合理设置线程池大小？**
    - **答**：CPU 密集型：`Ncpu + 1`；I/O 密集型：`2 * Ncpu`（或更多）。可通过公式 `Nthreads = Ncpu * Ucpu * (1 + W/C)` 计算，其中 Ucpu 为目标 CPU 利用率，W/C 为等待时间与计算时间的比率。

### AQS
10. **AQS 的原理？**
    - **答**：AQS 内部维护一个 volatile int state 和一个 CLH 双向队列。通过 CAS 修改 state，获取锁失败的线程进入队列等待。ReentrantLock、Semaphore、CountDownLatch 等都基于 AQS 实现。

### ThreadLocal
11. **ThreadLocal 的内存泄漏问题？**
    - **答**：ThreadLocalMap 的 key 是弱引用（WeakReference），但 value 是强引用。当 ThreadLocal 被 GC 回收后，key 变为 null，但 value 仍然存在，导致内存泄漏。解决：使用后调用 `remove()`。

### 其他
12. **什么是死锁？如何避免？**
    - **答**：死锁是两个或多个线程互相等待对方释放锁。避免：① 按固定顺序获取锁；② 使用 tryLock 设置超时；③ 使用死锁检测工具（jstack）。

13. **CAS 的 ABA 问题是什么？如何解决？**
    - **答**：ABA 问题是指变量值从 A 变成 B 又变回 A，CAS 误认为没有变化。解决：使用 `AtomicStampedReference` 或 `AtomicMarkableReference`，增加版本号标记。

---

## 🇨🇳 中文说明

本目录覆盖了 Java 并发编程的核心知识，包括线程基础、同步、锁、原子类、线程池、AQS 和 ThreadLocal。每个主题都配有带中文注释的代码示例和带答案的面试题。代码示例在 `src/` 目录下，可以直接编译运行。

---

*Concurrency is hard, but mastering it makes you a better engineer.* 🧵