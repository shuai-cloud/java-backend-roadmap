# HashMap in Java（Java 中的 HashMap）

---

## 1. What is HashMap? 什么是 HashMap？

**English:**

HashMap is a hash-based implementation of the `Map` interface in Java used to store key-value pairs.

It provides average O(1) time complexity for get and put operations.

**中文：**

HashMap 是 Java 中基于哈希表实现的 Map 结构，用于存储 key-value（键值对）。

在理想情况下，get 和 put 的时间复杂度是 O(1)。

---

## 2. Internal Structure 底层结构

**English:**

Since Java 8, HashMap is implemented using:

* Array (Node table)
* Linked List
* Red-Black Tree (for high collision cases)

**中文：**

JDK8 之后 HashMap 的底层结构包括：

* 数组（Node 数组）
* 链表（解决 hash 冲突）
* 红黑树（链表过长时优化性能）

---

## 3. How put() works put 方法执行流程

**English:**

When inserting a key-value pair:

1. Calculate hash
2. Compute index
3. Check bucket
4. Handle collision if necessary

**中文：**

插入数据时流程如下：

1. 计算 key 的 hash
2. 计算数组下标
3. 找到对应桶位置
4. 如果冲突则处理（链表/红黑树）

---

### Key formula 核心公式

```text id="hmf1"
index = (n - 1) & hash
```

---

## 4. Collision Handling 冲突处理

**English:**

HashMap handles collisions using:

* Linked List (default)
* Red-Black Tree (when size > 8)

**中文：**

HashMap 解决冲突的方式：

* 链表（默认）
* 红黑树（当链表长度 > 8 时转换）

---

## 5. Resize Mechanism 扩容机制

**English:**

When load factor exceeds 0.75, HashMap will resize:

* Double the capacity
* Rehash all elements

This is an expensive operation (O(n)).

**中文：**

当负载因子超过 0.75 时会触发扩容：

* 容量扩大为 2 倍
* 重新计算所有元素位置

这个过程是 O(n) 的，非常耗时。

---

## 6. Common Interview Questions 面试高频问题

### Q1: Why HashMap is not thread-safe? 为什么线程不安全？

**English:**
Because it has no synchronization mechanism.

**中文：**
因为 HashMap 没有加锁，多线程情况下会发生数据覆盖或结构异常。

---

### Q2: Why capacity is power of 2? 为什么容量是 2 的幂？

**English:**
To optimize index calculation using bit operations.

**中文：**
为了用位运算代替取模，提高性能。

---

## 7. Summary 总结

**English:**

HashMap is a high-performance key-value data structure based on array, linked list, and red-black tree.

**中文：**

HashMap 是一个基于数组 + 链表 + 红黑树的高性能 key-value 数据结构。
