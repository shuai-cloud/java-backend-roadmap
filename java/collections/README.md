# Collections 📚

> Java collection framework for backend engineers (3–5 years experience).  
> Java 集合框架核心知识，面试高频考点。

[![Java](https://img.shields.io/badge/Java-17%2B-orange)](https://openjdk.org/)

---

## 📖 Overview · 概览

This section covers the Java Collections Framework: List, Set, Map, Queue, and their implementations. Understanding internal data structures, time complexity, thread safety, and fail-fast behavior is crucial for writing efficient and correct code. Each topic includes code examples with Chinese comments and common interview questions with answers.

本章涵盖 Java 集合框架：List、Set、Map、Queue 及其实现。理解内部数据结构、时间复杂度、线程安全和快速失败机制对于编写高效正确的代码至关重要。每个主题都包含带中文注释的代码示例和带答案的常见面试题。

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

**注意事项**：
- `ArrayList` 基于数组实现，随机访问快，插入删除慢（尾部除外）。
- 如果预先知道元素数量，指定初始容量可以避免多次扩容。

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

**内部结构**（JDK 1.8+）：
- 数组 + 链表 / 红黑树
- 默认容量 16，负载因子 0.75
- 当链表长度 ≥ 8 且数组长度 ≥ 64 时，链表转为红黑树
- 当红黑树节点 ≤ 6 时，退化为链表

**扩容机制**：
- 当元素个数 > 容量 × 负载因子时，扩容为原来的 2 倍
- 重新计算每个元素的索引（rehash），但 JDK 1.8 优化为：要么在原位置，要么在原位置 + 旧容量

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

---

### 7️⃣ HashSet · 哈希集合
java

Set<String> set = new HashSet<>();

set.add("apple");

set.add("banana");

set.add("apple");           // 重复元素不会添加

// 底层使用 HashMap，元素作为 key，PRESENT 作为 value

// private static final Object PRESENT = new Object();

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

**内部机制**（JDK 1.8+）：
- 采用 CAS + synchronized 保证并发安全
- 数组 + 链表/红黑树，与 HashMap 类似
- 锁粒度：对数组中的每个 Node 加锁（细粒度锁）

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

## ❓ Interview Questions with Answers · 面试题（附答案）

### List

1. **ArrayList 和 LinkedList 的区别？各自的时间复杂度？**
    - **答**：ArrayList 基于数组，随机访问 O(1)，插入删除 O(n)（尾部 O(1) 均摊）；LinkedList 基于双向链表，随机访问 O(n)，插入删除 O(1)（已知位置）。ArrayList 适合读多写少，LinkedList 适合写多读少。

2. **ArrayList 扩容时为什么是 1.5 倍而不是 2 倍？**
    - **答**：1.5 倍是折中选择，既能减少扩容次数（相比 1.25 倍），又能避免浪费太多内存（相比 2 倍）。同时 1.5 倍可以通过移位运算 `oldCapacity + (oldCapacity >> 1)` 高效计算。

3. **Vector 和 ArrayList 的区别？Vector 为什么被淘汰？**
    - **答**：Vector 是线程安全的（方法使用 synchronized），但性能差；扩容时 Vector 翻倍，ArrayList 1.5 倍。Vector 被淘汰是因为它的线程安全实现过于粗粒度，在现代并发场景下不如 `Collections.synchronizedList` 或 `CopyOnWriteArrayList`。

### Map

4. **HashMap 的 put 方法执行流程（JDK 1.8）？**
    - **答**：① 计算 key 的 hash 值（二次扰动）；② 如果数组为空则初始化；③ 根据 hash 计算桶下标；④ 如果桶为空则直接插入；⑤ 如果桶不为空，遍历链表/红黑树：若找到相同 key 则覆盖 value；若未找到则在链表尾部插入（尾插法）；⑥ 如果链表长度 ≥ 8 且数组长度 ≥ 64，转为红黑树；⑦ 检查是否需要扩容（size > threshold）。

5. **HashMap 1.7 和 1.8 的区别？**
    - **答**：① 1.7 使用头插法（多线程下可能形成死循环），1.8 使用尾插法；② 1.8 引入红黑树，当链表长度 ≥ 8 且数组长度 ≥ 64 时转为红黑树，优化查询性能；③ 1.8 扩容时重新计算索引的算法优化（利用旧容量二进制高位判断，元素要么在原位置，要么在原位置+旧容量）。

6. **为什么 HashMap 的容量总是 2 的幂次？**
    - **答**：为了让 hash 值能够均匀分布，计算桶下标时使用 `(n - 1) & hash` 代替取模运算，前提是 n 是 2 的幂次。这样位运算效率高，且能充分利用 hash 的低位信息。

7. **为什么重写 equals 必须重写 hashCode？**
    - **答**：HashMap/HashSet 依赖 hashCode 确定桶位置，如果两个对象 equals 相等但 hashCode 不同，它们会被放到不同的桶中，导致无法正确找到对象。反之，如果 hashCode 相同但 equals 不等，会发生哈希碰撞，但不会出错。

8. **ConcurrentHashMap 如何保证线程安全？**
    - **答**：JDK 1.8 采用 CAS + synchronized 实现。对数组中的每个 Node 使用 synchronized 加锁，保证并发安全的同时提高了并发度（锁粒度从 Segment 细化到 Node）。put 操作先尝试 CAS 更新，失败则加 synchronized。

9. **ConcurrentHashMap 的 size() 方法如何实现？**
    - **答**：JDK 1.8 使用 baseCount 和 CounterCell 数组来统计元素个数。更新时先尝试 CAS 更新 baseCount，如果竞争激烈则使用 CounterCell 分散计数。size() 方法会累加 baseCount 和所有 CounterCell 的值，得到一个近似准确的计数（非实时精确，但足够满足需求）。

### Set

10. **HashSet 和 TreeSet 的区别？**
    - **答**：HashSet 基于 HashMap，无序，O(1) 操作；TreeSet 基于 TreeMap（红黑树），有序（自然顺序或自定义比较器），O(log n) 操作。

11. **HashSet 如何保证元素不重复？**
    - **答**：底层使用 HashMap，元素作为 key，一个固定的 Object 对象作为 value。HashMap 的 key 唯一性保证了 HashSet 的元素不重复。

### Queue

12. **PriorityQueue 底层数据结构？如何实现最大堆？**
    - **答**：底层使用 Object 数组实现的二叉堆（最小堆）。要实现最大堆，可以在构造时传入 `Comparator.reverseOrder()` 或 `(a, b) -> b - a`。

13. **ArrayDeque 和 LinkedList 作为队列的区别？**
    - **答**：ArrayDeque 基于循环数组，内存连续，随机访问快，没有节点开销，性能优于 LinkedList；LinkedList 基于链表，有节点开销，但支持在中间插入删除。作为队列使用时推荐 ArrayDeque。

### 其他

14. **fail-fast 和 fail-safe 的区别？**
    - **答**：fail-fast 在迭代过程中检测到结构性修改（增删）会立即抛出 ConcurrentModificationException，如 ArrayList、HashMap 的迭代器；fail-safe 在迭代时使用原集合的快照或拷贝，允许修改原集合，如 CopyOnWriteArrayList、ConcurrentHashMap 的迭代器。

15. **Collections.synchronizedList 和 CopyOnWriteArrayList 的区别？**
    - **答**：`Collections.synchronizedList` 使用包装器模式，所有方法加 synchronized 锁，读写都互斥；`CopyOnWriteArrayList` 写时复制（创建新数组），读操作不加锁，适合读多写少的场景。

---

## 🇨🇳 中文说明

本目录覆盖了 Java 集合框架的所有核心实现，每个集合都分析了内部数据结构、时间复杂度和线程安全性。代码示例在 `src/` 目录下，可以直接编译运行。面试题部分列出了最常考的问题并附有简要答案，建议结合源码深入理解。

---

*Master collections, master Java.* 📚