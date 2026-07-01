# Java ☕

> Core Java knowledge for backend engineers (3–5 years experience).  
> Java 后端工程师核心知识体系（3-5 年经验）。

[![Java](https://img.shields.io/badge/Java-17%2B-orange)](https://openjdk.org/)

---

## 📖 Overview · 概览

This section covers the fundamental and advanced Java topics required for senior backend roles. Whether you're preparing for interviews, returning to coding after a break, or applying to graduate programs, mastering these topics will demonstrate strong foundational skills and deep understanding.

本章涵盖高级后端岗位所需的 Java 基础和进阶知识。无论你是准备面试、回归编码，还是申请研究生项目，掌握这些主题都能展示扎实的基础和深入的理解。

---

## 🗂️ Directory Structure · 目录结构

java/

├── java-basics/           # Core syntax, OOP, exceptions, generics, annotations, reflection

├── collections/           # Collection framework (ArrayList, HashMap, ConcurrentHashMap, etc.)

├── io-nio/                # I/O streams, NIO, Netty basics

├── jvm/                   # JVM memory model, GC, class loading, tuning, OOM analysis

├── concurrency/           # Multithreading, JUC tools, thread pools, locks, AQS, CAS

├── lambda-stream/         # Lambda expressions, Stream API, Optional

├── design-patterns/       # Common patterns (singleton, factory, proxy, strategy, template)

├── leetcode/              # Data structures & algorithms (arrays, linked lists, trees, DP)

└── interview-questions/   # High-frequency interview questions with answers

Each subdirectory contains:
- A `README.md` with key concepts, comparisons, and interview tips.
- Runnable code examples in `src/` (Java files or unit tests).

每个子目录都包含概念总结、对比分析和面试提示，以及可运行的代码示例。

---

## 🎯 Learning Goals · 学习目标

By completing this section, you should be able to:

| Topic | Goal |
|-------|------|
| Java Basics | Explain OOP principles, exception handling, generics erasure, reflection usage |
| Collections | Compare internal structures of ArrayList vs LinkedList, HashMap vs ConcurrentHashMap |
| I/O & NIO | Understand blocking vs non-blocking, selectors, ByteBuffer |
| JVM | Describe memory regions, GC algorithms, class loading mechanism, tuning flags |
| Concurrency | Implement thread-safe code, explain AQS, thread pool parameters, volatile semantics |
| Lambda & Stream | Write functional-style code, chain stream operations |
| Design Patterns | Recognize patterns in Spring source code, implement singleton correctly |
| Algorithms | Solve medium LeetCode problems, analyze time/space complexity |
| Interview Prep | Answer common questions confidently with code examples |

---

## 📌 Key Interview Topics · 面试重点

### 1️⃣ Java Basics
- Object-oriented features (encapsulation, inheritance, polymorphism) · 面向对象三大特性
- Abstract class vs interface · 抽象类与接口区别
- Exception hierarchy (checked vs unchecked) · 异常体系
- Generics erasure, wildcards, type bounds · 泛型擦除与通配符
- Reflection: dynamic proxy, Spring IoC · 反射与动态代理

### 2️⃣ Collections
- ArrayList vs LinkedList (internal structure, expansion) · 底层结构与扩容
- HashMap 1.7 vs 1.8 (head insertion vs tail, red-black tree, resize) · HashMap 演变
- ConcurrentHashMap: segment lock vs CAS + synchronized · 并发安全实现
- TreeMap: red-black tree, Comparable vs Comparator · 红黑树与排序

### 3️⃣ JVM
- Memory areas (heap, stack, metaspace, direct memory) · 内存区域
- GC algorithms (mark-sweep, copying, mark-compact) · 垃圾回收算法
- Garbage collectors (Serial, Parallel, CMS, G1, ZGC) · 常见回收器
- Class loading process, parent delegation model · 类加载与双亲委派
- JVM tuning parameters (-Xms, -Xmx, -XX:+PrintGCDetails) · 调优参数
- OOM diagnosis (heap dump, MAT analysis) · OOM 排查

### 4️⃣ Concurrency
- Thread states, wait/notify, sleep/yield/join · 线程状态与协作
- synchronized principle (biased lock, lightweight, heavyweight) · 锁升级
- volatile visibility & happens-before · 可见性与有序性
- AQS framework, ReentrantLock, CountDownLatch, Semaphore · AQS 原理
- ThreadPoolExecutor parameters (corePoolSize, maxPoolSize, queue, reject) · 线程池参数
- ThreadLocal principle & memory leak · ThreadLocal 与内存泄漏

### 5️⃣ Others
- Lambda & Stream common operations · Lambda 与 Stream 常用操作
- Singleton pattern (double-checked locking, enum) · 单例模式
- Factory, Strategy, Template Method patterns in Spring · 设计模式在 Spring 中的应用
- Java 8+ features (Optional, CompletableFuture, Date/Time API) · Java 8 新特性

---

## 🚀 How to Use · 如何使用

1. **Start from `java-basics/`** if you're reviewing fundamentals after a break.
2. **Focus on `collections/` and `jvm/`** for interview-heavy topics.
3. **Practice coding** in `leetcode/` and `concurrency/src/` regularly.
4. **Review `interview-questions/`** before actual interviews.
5. **Commit code frequently** to show consistent effort on GitHub.

---

## 📅 Recommended Study Plan · 学习计划建议

| Week | Focus | Deliverable |
|------|-------|-------------|
| 1 | Java Basics + Collections | Complete README + 5 code examples |
| 2 | JVM + I/O | Write GC log analysis demo |
| 3 | Concurrency | Implement thread-safe cache, thread pool demo |
| 4 | Lambda + Design Patterns | Refactor old code with streams |
| 5 | LeetCode (Easy/Medium) | 10 solved problems with comments |
| 6 | Interview Questions Review | Summarize top 30 Q&A |

---

## 🇨🇳 中文说明

本目录专为 Java 后端 3-5 年经验工程师整理，覆盖从基础语法到 JVM 调优、并发编程的全套知识体系。每个子目录都配有中文注解和面试高频题，适合快速复习和查漏补缺。  
如果你有一年多没写代码，建议从 `java-basics` 开始，逐步过渡到 `collections` 和 `jvm`，最后攻克 `concurrency`。

---

*Back to basics, back to confidence.* 💪