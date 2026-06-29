# LinkedList in Java | Java中的LinkedList

---

## 1. What is LinkedList?
## 什么是 LinkedList？

English:

LinkedList is a doubly linked list implementation of the List interface.

中文：

LinkedList 是 Java 中基于双向链表实现的 List 接口实现类。

---

## 2. Internal Structure
## 底层结构

LinkedList is implemented using a doubly linked list.

LinkedList 底层采用双向链表实现。

Structure:

NULL <- Node <-> Node <-> Node -> NULL

Each node contains:

每个节点包含：

- previous
- next
- item

3. Advantages
优点
Fast insertion and deletion.
No resize operation.
Suitable for frequent insert/remove scenarios.

中文：

插入删除效率高
不需要扩容
适合频繁增删场景
4. Disadvantages
缺点
Slow random access.
Higher memory usage.

中文：

随机访问效率低
占用更多内存

5. Time Complexity
时间复杂度
Operation	ArrayList	LinkedList
get(index)	O(1)	O(n)
add()	O(1)	O(1)
add(index)	O(n)	O(n)
remove(index)	O(n)	O(n)

6. Interview Questions
高频面试题
Q1: ArrayList 和 LinkedList 的区别？
ArrayList	LinkedList
Dynamic Array	Doubly Linked List
Fast Random Access	Fast Insert/Delete
Resize Required	No Resize
Better Cache Locality	Poor Cache Locality
Q2: 为什么 LinkedList 查询慢？

因为需要从头节点或者尾节点开始遍历查找目标元素。

Because LinkedList needs traversal from head or tail node.

Q3: LinkedList 是单向链表还是双向链表？

Java LinkedList is a doubly linked list.

Java 的 LinkedList 是双向链表。

7. Summary
总结

ArrayList 适合查询多、修改少。

LinkedList 适合修改多、查询少。

实际企业开发中：

默认优先选择 ArrayList。
只有明确存在大量插入删除需求时才考虑 LinkedList。