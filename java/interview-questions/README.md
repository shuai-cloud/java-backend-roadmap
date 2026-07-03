# Interview Questions ❓

> Java interview questions for backend engineers (3–5 years experience).  
> Java 面试题汇总，按主题分类，附简要答案。

[![Java](https://img.shields.io/badge/Java-17%2B-orange)](https://openjdk.org/)

---

## 📖 Overview · 概览

This section collects high-frequency Java interview questions organized by topic. Each question includes a concise answer suitable for oral interviews. Use this as a quick revision checklist before interviews.

本章按主题整理了 Java 高频面试题，每题附有适合口述的简要答案。可作为面试前的快速复习清单。

---

## 🗂️ Topics · 主题速查

### 1️⃣ Java Basics · Java 基础

**Q1: 面向对象三大特性是什么？**
- **封装**：隐藏内部实现，通过公共方法暴露接口。
- **继承**：子类复用父类代码，支持扩展。
- **多态**：同一接口不同实现，通过父类引用调用子类方法。

**Q2: 抽象类和接口的区别（Java 8+）？**
- 抽象类可以有构造方法、成员变量、具体方法和抽象方法；接口只能有常量、抽象方法、默认方法和静态方法。
- 一个类只能继承一个抽象类，但可以实现多个接口。
- 抽象类用于 `is-a` 关系，接口用于 `can-do` 能力。

**Q3: `==` 和 `equals()` 的区别？**
- `==` 比较基本类型值或引用类型的内存地址。
- `equals()` 默认比较引用，但通常被重写为比较内容（如 String、Integer）。

**Q4: `final` 关键字的作用？**
- 修饰类：不能被继承。
- 修饰方法：不能被重写。
- 修饰变量：常量（基本类型值不变，引用类型引用不变）。

**Q5: 重载和重写的区别？**
- 重载：同一类中，方法名相同参数列表不同，编译时多态。
- 重写：父子类中，方法签名完全相同，运行时多态。

---

### 2️⃣ Collections · 集合

**Q6: ArrayList 和 LinkedList 的区别？**
- ArrayList：数组实现，随机访问 O(1)，插入删除 O(n)（尾部 O(1)）。
- LinkedList：双向链表实现，随机访问 O(n)，插入删除 O(1)（已知位置）。
- ArrayList 适合读多写少，LinkedList 适合写多读少。

**Q7: HashMap 1.7 和 1.8 的区别？**
- 1.7 头插法（多线程死循环），1.8 尾插法。
- 1.8 引入红黑树（链表≥8 且数组≥64 时转换），优化查询。
- 1.8 扩容时 rehash 优化（元素要么在原位置，要么在原位置+旧容量）。

**Q8: ConcurrentHashMap 如何保证线程安全？**
- JDK 1.8：CAS + synchronized，锁粒度为数组中的每个 Node。
- 读操作无锁，写操作对 Node 加锁，提高并发度。

**Q9: 为什么重写 equals 必须重写 hashCode？**
- HashMap/HashSet 依赖 hashCode 确定桶位置。
- 如果 equals 相等但 hashCode 不同，会被放到不同桶，导致无法正确找到。

---

### 3️⃣ JVM

**Q10: JVM 内存区域有哪些？**
- 堆（对象）、元空间（类元数据）、虚拟机栈（局部变量、操作数栈）、本地方法栈、程序计数器。

**Q11: 如何判断对象是否可回收？**
- 可达性分析：从 GC Roots 出发，不可达的对象可回收。
- GC Roots 包括：栈帧中的引用、静态属性引用、JNI 引用等。

**Q12: CMS 和 G1 的区别？**
- CMS：低延迟，标记-清除，产生碎片，无法处理浮动垃圾。
- G1：Region 划分，可预测停顿，JDK 9+ 默认。

**Q13: 双亲委派模型的作用？**
- 保证核心类库安全（如 `java.lang.String` 不会被篡改），避免重复加载。

---

### 4️⃣ Concurrency · 并发

**Q14: synchronized 的底层实现？**
- 基于 Monitor 对象，字节码使用 monitorenter/monitorexit。
- JDK 6 优化：偏向锁 → 轻量锁（CAS 自旋）→ 重量锁（操作系统互斥量）。

**Q15: volatile 的作用？**
- 保证可见性（写立即刷新到主内存，读从主内存读取）。
- 禁止指令重排（内存屏障）。
- 不保证原子性。

**Q16: 线程池的核心参数？**
- corePoolSize（核心线程数）、maximumPoolSize（最大线程数）、keepAliveTime（空闲存活时间）、workQueue（阻塞队列）、threadFactory（线程工厂）、rejectionHandler（拒绝策略）。

**Q17: 线程池的拒绝策略？**
- AbortPolicy（抛异常）、CallerRunsPolicy（调用者线程执行）、DiscardPolicy（丢弃）、DiscardOldestPolicy（丢弃队列最旧任务）。

**Q18: ThreadLocal 的内存泄漏问题？**
- ThreadLocalMap 的 key 是弱引用，但 value 是强引用。
- 如果 ThreadLocal 被回收而 value 未 remove，会导致内存泄漏。
- 解决：使用后调用 `remove()`。

---

### 5️⃣ I/O & NIO

**Q19: BIO、NIO、AIO 的区别？**
- BIO：同步阻塞，一个连接一个线程。
- NIO：同步非阻塞，Selector 多路复用，一个线程管理多连接。
- AIO：异步非阻塞，操作系统完成 I/O 后回调。

**Q20: 什么是零拷贝？Java 中如何实现？**
- 数据从磁盘到网络（或反之）时避免在内核空间和用户空间之间拷贝。
- Java 通过 `FileChannel.transferTo()` / `transferFrom()` 实现。

---

### 6️⃣ Spring Framework

**Q21: IOC 和 DI 的区别？**
- IOC（控制反转）：对象创建和依赖管理的控制权从程序转移到容器。
- DI（依赖注入）：IOC 的一种实现方式，容器通过构造器、Setter 或字段注入依赖。

**Q22: Spring Bean 的生命周期？**
- 实例化 → 属性赋值 → Aware 接口回调 → BeanPostProcessor 前置处理 → InitializingBean / init-method → BeanPostProcessor 后置处理 → 使用 → DisposableBean / destroy-method。

**Q23: Spring 事务的传播行为有哪些？**
- REQUIRED（默认，支持当前事务，没有则新建）、REQUIRES_NEW（新建事务，挂起当前事务）、SUPPORTS（支持当前事务，没有则以非事务方式执行）、MANDATORY（必须有事务）、NOT_SUPPORTED（非事务方式）、NEVER（不能有事务）、NESTED（嵌套事务）。

**Q24: Spring AOP 的原理？**
- 基于动态代理：目标类有接口则使用 JDK 动态代理，否则使用 CGLIB 代理。
- 切面（Aspect）由切点（Pointcut）和通知（Advice）组成。

---

### 7️⃣ MySQL

**Q25: 索引的类型？**
- B+Tree 索引（聚簇索引、非聚簇索引）、Hash 索引、全文索引。
- 聚簇索引：数据和索引存储在一起，InnoDB 的主键索引。
- 非聚簇索引：索引和数据分开存储，叶子节点存储主键值。

**Q26: 什么是覆盖索引？**
- 查询所需字段全部包含在索引中，无需回表查询，减少 I/O。

**Q27: SQL 优化的一般步骤？**
- EXPLAIN 分析执行计划 → 检查 type（ALL 需要优化）→ 检查 Extra（Using filesort、Using temporary 需要优化）→ 添加合适索引 → 优化查询语句。

**Q28: 事务的 ACID 特性？**
- 原子性（Atomicity）、一致性（Consistency）、隔离性（Isolation）、持久性（Durability）。

**Q29: MVCC 的原理？**
- 多版本并发控制，通过隐藏字段（DB_TRX_ID、DB_ROLL_PTR）和 undo log 实现。
- 每行数据有多个版本，事务根据隔离级别读取合适的版本。

---

### 8️⃣ Redis

**Q30: Redis 的数据类型？**
- String、List、Set、Sorted Set（ZSet）、Hash、Bitmaps、HyperLogLog、Geospatial、Stream。

**Q31: Redis 的过期策略？**
- 定期删除（每隔 100ms 随机抽取一部分 key 检查过期）+ 惰性删除（访问时检查过期）。

**Q32: Redis 的持久化方式？**
- RDB（快照）：定时生成全量快照，适合备份。
- AOF（追加文件）：记录每次写操作，数据更可靠。
- 混合持久化（Redis 4.0+）：RDB + AOF 结合。

**Q33: 缓存穿透、缓存击穿、缓存雪崩的区别和解决方案？**
- 穿透：查询不存在的数据，缓存和数据库都没有。解决：布隆过滤器、缓存空值。
- 击穿：热点 key 过期，大量请求打到数据库。解决：互斥锁、永不过期。
- 雪崩：大量 key 同时过期，数据库压力骤增。解决：过期时间加随机值、多级缓存。

---

### 9️⃣ Distributed Systems · 分布式

**Q34: CAP 理论？**
- Consistency（一致性）、Availability（可用性）、Partition Tolerance（分区容忍性）三者不可兼得。
- 分布式系统通常选择 AP 或 CP。

**Q35: BASE 理论？**
- Basically Available（基本可用）、Soft State（软状态）、Eventually Consistent（最终一致性）。
- 是对 CAP 中 AP 的补充。

**Q36: 分布式事务的实现方式？**
- 2PC（两阶段提交）、TCC（Try-Confirm-Cancel）、Saga 模式、本地消息表、RocketMQ 事务消息。

**Q37: 负载均衡算法？**
- 轮询、加权轮询、最少连接、IP Hash、一致性哈希。

---

### 🔟 System Design · 系统设计

**Q38: 设计一个短链接系统？**
- 核心功能：长链接转短链接、重定向、统计访问次数。
- 架构：生成唯一 ID（雪花算法或发号器）→ 存储映射关系（Redis + DB）→ 302 重定向。
- 优化：预生成 ID、CDN 加速、布隆过滤器防恶意访问。

**Q39: 设计一个秒杀系统？**
- 核心挑战：高并发、库存扣减、防超卖。
- 方案：前端限流（按钮置灰、验证码）→ 后端削峰（MQ 排队）→ Redis 原子扣减库存 → 异步落库。
- 优化：静态化页面、CDN 缓存、限流降级。

---

## 📚 How to Use · 如何使用

1. **按主题复习**：每天选择一个主题，看完所有问题后尝试口头回答。
2. **模拟面试**：找朋友或录音，模拟真实面试环境。
3. **深入扩展**：对于不理解的问题，回到对应的子目录（如 `jvm/`、`concurrency/`）查阅详细内容。
4. **补充笔记**：在 `src/` 目录下可以添加自己的笔记和代码片段。

---

## 🇨🇳 中文说明

本目录汇总了 Java 后端面试中最高频的问题，按主题分类并附有简要答案。适合面试前快速复习。每个问题的详细原理和代码示例可以在对应的子目录中找到。

---

*Prepare thoroughly, interview confidently.* ❓