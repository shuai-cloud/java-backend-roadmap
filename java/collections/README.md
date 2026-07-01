# Collections 📚

> Java collection framework for backend engineers (3–5 years experience).  
> Java 集合框架核心知识，面试高频考点。

[![Java](https://img.shields.io/badge/Java-17%2B-orange)](https://openjdk.org/)

---

## 📖 Overview · 概览

This section covers the Java Collections Framework: List, Set, Map, Queue, and their implementations. Understanding internal data structures, time complexity, thread safety, and fail-fast behavior is crucial for writing efficient and correct code. Each topic includes code examples with Chinese comments and common interview questions.

本章涵盖 Java 集合框架：List、Set、Map、Queue 及其实现。理解内部数据结构、时间复杂度、线程安全和快速失败机制对于编写高效正确的代码至关重要。每个主题都包含带中文注释的代码示例和常见面试题。

---

## 🗂️ Topics · 主题速查

### 1️⃣ Collection Framework Overview · 集合框架概览

Collection (interface)

├── List (有序、可重复)

│   ├── ArrayList (数组实现)

│   ├── LinkedList (双向链表)

│   └── Vector (线程安全，已淘汰)

├── Set (无序、不可重复)

│   ├── HashSet (基于 HashMap)

│   ├── LinkedHashSet (维护插入顺序)

│   └── TreeSet (红黑树，排序)

└── Queue (队列)

├── LinkedList (双端队列)

├── PriorityQueue (优先级队列)

└── ArrayDeque (数组双端队列)

Map (interface)

├── HashMap (数组+链表/红黑树)

├── LinkedHashMap (维护插入顺序或访问顺序)

├── TreeMap (红黑树，排序)

└── ConcurrentHashMap (线程安全)

纯文本
---

### 2️⃣ ArrayList · 数组列表

java

// 创建

List<String> list = new ArrayList<>();       // 默认容量10

List<String> list2 = new ArrayList<>(100);   // 指定初始容量

// 常用操作

list.add("A");                               // 尾部添加 O(1) 均摊

list.add(0, "B");                            // 指定位置插入 O(n)

list.get(1);                                 // 随机访问 O(1)

list.remove(0);                              // 删除 O(n)

list.contains("A");                          // 线性查找 O(n)

// 扩容机制：当容量不足时，新容量 = 旧容量 * 1.5（右移一位）

// 源码：int newCapacity = oldCapacity + (oldCapacity >> 1);

纯文本
**注意事项**：
- `ArrayList` 基于数组实现，随机访问快，插入删除慢（尾部除外）。
- 如果预先知道元素数量，指定初始容量可以避免多次扩容。

**面试题**：
- ArrayList 的扩容机制是怎样的？为什么是 1.5 倍？
- ArrayList 和 LinkedList 的区别？各自适用场景？

---

### 3️⃣ LinkedList · 链表

java

LinkedList<String> list = new LinkedList<>();

// 作为 List 使用

list.add("A");

list.add(0, "B");               // 头插 O(1)，因为双向链表

// 作为 Deque 使用

list.addFirst("X");             // 头插

list.addLast("Z");              // 尾插

list.removeFirst();

list.removeLast();

// 作为 Queue 使用

list.offer("Q");                // 入队（尾）

String head = list.poll();      // 出队（头）

String peek = list.peek();      // 查看队头不移除

纯文本
**注意事项**：
- `LinkedList` 基于双向链表实现，插入删除快（已知位置 O(1)），随机访问慢 O(n)。
- 实现了 `List`、`Deque`、`Queue` 三个接口。

---

### 4️⃣ HashMap · 哈希映射

java

Map<String, Integer> map = new HashMap<>();

// 常用操作

map.put("apple", 10);            // 插入/更新

int value = map.get("apple");    // 获取，不存在返回 null

int value2 = map.getOrDefault("banana", 0); // 不存在返回默认值

map.containsKey("apple");        // 判断 key 是否存在

map.remove("apple");             // 删除

// 遍历

for (Map.Entry<String, Integer> entry : map.entrySet()) {

System.out.println(entry.getKey() + ":" + entry.getValue());

}

纯文本
**内部结构**（JDK 1.8+）：
- 数组 + 链表 / 红黑树
- 默认容量 16，负载因子 0.75
- 当链表长度 ≥ 8 且数组长度 ≥ 64 时，链表转为红黑树
- 当红黑树节点 ≤ 6 时，退化为链表

**扩容机制**：
- 当元素个数 > 容量 × 负载因子时，扩容为原来的 2 倍
- 重新计算每个元素的索引（rehash），但 JDK 1.8 优化为：要么在原位置，要么在原位置 + 旧容量

**注意事项**：
- HashMap 是非线程安全的，多线程环境下使用 `ConcurrentHashMap`。
- key 和 value 都可以为 null，但 key 最多一个 null。

**面试题**：
- HashMap 1.7 和 1.8 的区别（头插法 vs 尾插法、红黑树引入、扩容优化）？
- 为什么链表长度达到 8 才转红黑树？
- HashMap 的 put 方法流程？
- 为什么重写 `equals()` 时必须重写 `hashCode()`？

---

### 5️⃣ LinkedHashMap · 有序哈希映射

java

// 维护插入顺序（默认）

Map<String, Integer> map = new LinkedHashMap<>();

map.put("a", 1);

map.put("b", 2);

// 遍历顺序：a -> b

// 维护访问顺序（LRU 缓存）

LinkedHashMap<String, Integer> lru = new LinkedHashMap<>(16, 0.75f, true) {

@Override

protected boolean removeEldestEntry(Map.Entry eldest) {

return size() > 3;  // 最多缓存 3 个

}

};

lru.put("a", 1);

lru.put("b", 2);

lru.put("c", 3);

lru.get("a");               // 访问 a，a 移到末尾

lru.put("d", 4);            // 超出容量，移除最老的 b

纯文本
---

### 6️⃣ TreeMap · 树形映射

java

// 自然排序（key 必须实现 Comparable）

Map<String, Integer> map = new TreeMap<>();

// 自定义排序

Map<String, Integer> sortedMap = new TreeMap<>((a, b) -> b.compareTo(a)); // 降序

// 常用方法

sortedMap.put("a", 1);

sortedMap.put("c", 3);

sortedMap.put("b", 2);

System.out.println(sortedMap.firstKey());   // c（降序的第一个）

System.out.println(sortedMap.lastKey());    // a

System.out.println(sortedMap.subMap("b", "d")); // 子视图

纯文本
**注意事项**：
- `TreeMap` 基于红黑树实现，所有操作 O(log n)。
- key 必须实现 `Comparable` 或在构造时传入 `Comparator`。

---

### 7️⃣ HashSet · 哈希集合

java

Set<String> set = new HashSet<>();

set.add("apple");

set.add("banana");

set.add("apple");           // 重复元素不会添加

// 底层使用 HashMap，元素作为 key，PRESENT 作为 value

// private static final Object PRESENT = new Object();

纯文本
---

### 8️⃣ ConcurrentHashMap · 并发哈希映射

java

Map<String, Integer> map = new ConcurrentHashMap<>();

// 线程安全，支持高并发

map.put("key", 1);

Integer value = map.get("key");

// 原子操作

map.putIfAbsent("key", 2);      // 仅当 key 不存在时才 put

map.computeIfAbsent("key", k -> computeValue(k));

纯文本
**内部机制**（JDK 1.8+）：
- 采用 CAS + synchronized 保证并发安全
- 数组 + 链表/红黑树，与 HashMap 类似
- 锁粒度：对数组中的每个 Node 加锁（细粒度锁）

**面试题**：
- ConcurrentHashMap 1.7 和 1.8 的区别（Segment 分段锁 vs CAS + synchronized）？
- ConcurrentHashMap 的 size() 方法如何实现？
- ConcurrentHashMap 的迭代器是 fail-safe 还是 fail-fast？

---

### 9️⃣ Queue & Deque · 队列与双端队列

java

// 优先级队列（最小堆）

Queue<Integer> pq = new PriorityQueue<>();

pq.offer(3);

pq.offer(1);

pq.offer(2);

System.out.println(pq.poll());  // 1（最小值）

// 最大堆

Queue<Integer> maxPq = new PriorityQueue<>((a, b) -> b - a);

// ArrayDeque（数组双端队列，比 LinkedList 更快）

Deque<String> deque = new ArrayDeque<>();

deque.addFirst("A");

deque.addLast("B");

deque.removeFirst();

纯文本
---

### 🔟 Fail-Fast vs Fail-Safe · 快速失败 vs 安全失败

java

// fail-fast：迭代过程中修改结构会抛出 ConcurrentModificationException

List<String> list = new ArrayList<>();

list.add("a");

Iterator<String> it = list.iterator();

list.add("b");          // 结构性修改

it.next();              // 抛出 ConcurrentModificationException

// fail-safe：迭代在副本上进行，允许修改原集合

CopyOnWriteArrayList<String> cowList = new CopyOnWriteArrayList<>();

cowList.add("a");

Iterator<String> it2 = cowList.iterator();

cowList.add("b");       // 修改原集合

it2.next();             // 正常，迭代的是旧快照

纯文本
---

## 📂 Code Examples · 代码示例

All runnable code examples are located in the [`src/`](./src/) directory:

| File | Description |
|------|-------------|
| `ArrayListDemo.java` | ArrayList 扩容、增删改查、遍历 |
| `LinkedListDemo.java` | LinkedList 作为 List/Queue/Deque 使用 |
| `HashMapDemo.java` | HashMap 基本操作、遍历、扩容观察 |
| `LinkedHashMapDemo.java` | LRU 缓存实现 |
| `TreeMapDemo.java` | 排序、子视图 |
| `ConcurrentHashMapDemo.java` | 并发安全操作 |
| `QueueDemo.java` | PriorityQueue, ArrayDeque |
| `FailFastDemo.java` | fail-fast vs fail-safe 对比 |

---

## ❓ Interview Questions · 面试题

### List
1. ArrayList 和 LinkedList 的区别？各自的时间复杂度？
2. ArrayList 扩容时为什么是 1.5 倍而不是 2 倍？
3. Vector 和 ArrayList 的区别？Vector 为什么被淘汰？

### Map
4. HashMap 的 put 方法执行流程（JDK 1.8）？
5. HashMap 1.7 和 1.8 的区别？
6. 为什么 HashMap 的容量总是 2 的幂次？
7. 为什么重写 equals 必须重写 hashCode？
8. ConcurrentHashMap 如何保证线程安全？
9. ConcurrentHashMap 的 size() 方法如何实现？

### Set
10. HashSet 和 TreeSet 的区别？
11. HashSet 如何保证元素不重复？

### Queue
12. PriorityQueue 底层数据结构？如何实现最大堆？
13. ArrayDeque 和 LinkedList 作为队列的区别？

### 其他
14. fail-fast 和 fail-safe 的区别？
15. Collections.synchronizedList 和 CopyOnWriteArrayList 的区别？

---

## 🇨🇳 中文说明

本目录覆盖了 Java 集合框架的所有核心实现，每个集合都分析了内部数据结构、时间复杂度和线程安全性。代码示例在 `src/` 目录下，可以直接编译运行。面试题部分列出了最常考的问题，建议结合源码理解。

---

*Master collections, master Java.* 📚