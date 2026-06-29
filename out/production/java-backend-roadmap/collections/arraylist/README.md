# ArrayList in Java（Java 中的 ArrayList）

---

## 1. What is ArrayList? 什么是 ArrayList？

**English:**

ArrayList is a dynamic array implementation in Java that can grow automatically when needed.

**中文：**

ArrayList 是 Java 提供的动态数组结构，底层是数组，但可以自动扩容。

---

## 2. Internal Structure 底层结构

**English:**

ArrayList is based on a normal array:

```text id="a1"
Object[]
```

When capacity is full, it creates a new larger array and copies elements.

**中文：**

ArrayList 底层就是一个 Object 数组，当容量不足时会：

* 创建新数组
* 拷贝旧数据
* 替换引用

---

## 3. How add() works add 方法流程

**English:**

1. Check capacity
2. If full → resize
3. Insert element

**中文：**

1. 检查容量
2. 如果满了 → 扩容
3. 插入元素

---

## 4. Resize Mechanism 扩容机制

**English:**

New capacity = old capacity × 1.5

**中文：**

扩容规则：

> 新容量 = 原容量 × 1.5 倍

---

## 5. Time Complexity 时间复杂度

| Operation | Complexity     |
| --------- | -------------- |
| get       | O(1)           |
| add       | O(1) amortized |
| remove    | O(n)           |

---

## 6. Fail-Fast Mechanism（重点）

**English:**

ArrayList uses a modCount to detect concurrent modification.

**中文：**

ArrayList 内部有 modCount，用来检测并发修改，避免数据不一致。

---

## 7. Common Interview Questions 面试题

### Q1: Why ArrayList is not thread-safe?

**English:**
Because it has no synchronization.

**中文：**
因为没有加锁，多线程环境下会出现数据不一致。

---

### Q2: Difference between ArrayList and LinkedList?

* ArrayList: array-based, fast random access
* LinkedList: node-based, fast insertion/deletion

---

## 8. Summary 总结

**English:**

ArrayList is a resizable array used for fast random access.

**中文：**

ArrayList 是基于数组实现的动态集合，适合快速随机访问。
