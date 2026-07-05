# LeetCode & Algorithms 🧮

> Data structures and algorithms for backend engineers (3–5 years experience).  
> 数据结构与算法，面试必考。

[![Java](https://img.shields.io/badge/Java-17%2B-orange)](https://openjdk.org/)

---

## 📖 Overview · 概览

This section covers the most important data structures and algorithms for coding interviews. Each topic includes problem-solving patterns, time/space complexity analysis, and Java code examples with Chinese comments. The goal is to build a systematic understanding rather than memorizing solutions.

本章涵盖编码面试中最重要的数据结构和算法。每个主题包括解题模式、时间/空间复杂度分析和带中文注释的 Java 代码示例。目标是建立系统性的理解，而不是死记硬背答案。

---

## 🗂️ Topics · 主题速查

### 1️⃣ Big O Notation · 时间复杂度

| Notation | Name | Example |
|----------|------|---------|
| O(1) | Constant | Array access, HashMap get |
| O(log n) | Logarithmic | Binary search, balanced BST |
| O(n) | Linear | Array traversal, linear search |
| O(n log n) | Linearithmic | Merge sort, quicksort average |
| O(n²) | Quadratic | Bubble sort, nested loops |
| O(2ⁿ) | Exponential | Recursive Fibonacci (naive) |

**注意事项**：
- 分析复杂度时考虑最坏情况。
- 空间复杂度同样重要，注意是否使用了额外数据结构。

---

### 2️⃣ Array & Two Pointers · 数组与双指针
java

// 两数之和（LeetCode 1）

public int[] twoSum(int[] nums, int target) {

Map<Integer, Integer> map = new HashMap<>();

for (int i = 0; i < nums.length; i++) {

int complement = target - nums[i];

if (map.containsKey(complement)) {

return new int[]{map.get(complement), i};

}

map.put(nums[i], i);

}

return new int[]{-1, -1};

}

// 盛最多水的容器（LeetCode 11）- 双指针

public int maxArea(int[] height) {

int left = 0, right = height.length - 1;

int maxWater = 0;

while (left < right) {

int width = right - left;

int h = Math.min(height[left], height[right]);

maxWater = Math.max(maxWater, width * h);

if (height[left] < height[right]) {

left++;

} else {

right--;

}

}

return maxWater;

}

纯文本
**常见题型**：
- 两数之和、三数之和
- 盛水容器、接雨水
- 移动零、合并有序数组

---

### 3️⃣ Sliding Window · 滑动窗口
java

// 无重复字符的最长子串（LeetCode 3）

public int lengthOfLongestSubstring(String s) {

Set<Character> set = new HashSet<>();

int left = 0, maxLen = 0;

for (int right = 0; right < s.length(); right++) {

while (set.contains(s.charAt(right))) {

set.remove(s.charAt(left));

left++;

}

set.add(s.charAt(right));

maxLen = Math.max(maxLen, right - left + 1);

}

return maxLen;

}

纯文本
**常见题型**：
- 无重复字符的最长子串
- 最小覆盖子串
- 滑动窗口最大值

---

### 4️⃣ Linked List · 链表
java

// 反转链表（LeetCode 206）

public ListNode reverseList(ListNode head) {

ListNode prev = null;

ListNode curr = head;

while (curr != null) {

ListNode nextTemp = curr.next;

curr.next = prev;

prev = curr;

curr = nextTemp;

}

return prev;

}

// 环形链表检测（LeetCode 141）

public boolean hasCycle(ListNode head) {

ListNode slow = head, fast = head;

while (fast != null && fast.next != null) {

slow = slow.next;

fast = fast.next.next;

if (slow == fast) return true;

}

return false;

}

纯文本
**常见题型**：
- 反转链表（迭代/递归）
- 合并两个有序链表
- 环形链表检测
- 相交链表
- 删除倒数第 N 个节点

---

### 5️⃣ Stack & Queue · 栈与队列
java

// 有效的括号（LeetCode 20）

public boolean isValid(String s) {

Map<Character, Character> map = Map.of(')', '(', '}', '{', ']', '[');

Deque<Character> stack = new ArrayDeque<>();

for (char c : s.toCharArray()) {

if (map.containsKey(c)) {

if (stack.isEmpty() || stack.pop() != map.get(c)) {

return false;

}

} else {

stack.push(c);

}

}

return stack.isEmpty();

}

// 单调栈：每日温度（LeetCode 739）

public int[] dailyTemperatures(int[] temperatures) {

int n = temperatures.length;

int[] answer = new int[n];

Deque<Integer> stack = new ArrayDeque<>();  // 存储索引

for (int i = 0; i < n; i++) {

while (!stack.isEmpty() && temperatures[i] > temperatures[stack.peek()]) {

int idx = stack.pop();

answer[idx] = i - idx;

}

stack.push(i);

}

return answer;

}

纯文本
---

### 6️⃣ Binary Tree · 二叉树
java

// 二叉树遍历

class TreeNode {

int val;

TreeNode left, right;

TreeNode(int x) { val = x; }

}

// 前序遍历（递归）

public void preorder(TreeNode root) {

if (root == null) return;

System.out.print(root.val + " ");

preorder(root.left);

preorder(root.right);

}

// 前序遍历（迭代）

public List<Integer> preorderIterative(TreeNode root) {

List<Integer> result = new ArrayList<>();

Deque<TreeNode> stack = new ArrayDeque<>();

stack.push(root);

while (!stack.isEmpty()) {

TreeNode node = stack.pop();

if (node != null) {

result.add(node.val);

stack.push(node.right);  // 先右后左

stack.push(node.left);

}

}

return result;

}

// 二叉树的最大深度（LeetCode 104）

public int maxDepth(TreeNode root) {

if (root == null) return 0;

return 1 + Math.max(maxDepth(root.left), maxDepth(root.right));

}

纯文本
**常见题型**：
- 二叉树遍历（前序/中序/后序/层序）
- 最大深度、平衡二叉树
- 验证二叉搜索树
- 最近公共祖先
- 路径总和

---

### 7️⃣ Heap & Priority Queue · 堆与优先队列
java

// 数组中的第 K 个最大元素（LeetCode 215）

public int findKthLargest(int[] nums, int k) {

PriorityQueue<Integer> minHeap = new PriorityQueue<>(k);

for (int num : nums) {

minHeap.offer(num);

if (minHeap.size() > k) {

minHeap.poll();  // 保持堆大小为 k

}

}

return minHeap.peek();

}

// 前 K 个高频元素（LeetCode 347）

public int[] topKFrequent(int[] nums, int k) {

Map<Integer, Integer> freq = new HashMap<>();

for (int num : nums) freq.put(num, freq.getOrDefault(num, 0) + 1);

PriorityQueue<Integer> heap = new PriorityQueue<>((a, b) -> freq.get(a) - freq.get(b));

for (int key : freq.keySet()) {

heap.offer(key);

if (heap.size() > k) heap.poll();

}

return heap.stream().mapToInt(Integer::intValue).toArray();

}

纯文本
---

### 8️⃣ Dynamic Programming · 动态规划
java

// 斐波那契数列（DP 优化空间）

public int fib(int n) {

if (n <= 1) return n;

int prev2 = 0, prev1 = 1;

for (int i = 2; i <= n; i++) {

int curr = prev1 + prev2;

prev2 = prev1;

prev1 = curr;

}

return prev1;

}

// 爬楼梯（LeetCode 70）

public int climbStairs(int n) {

if (n <= 2) return n;

int prev2 = 1, prev1 = 2;

for (int i = 3; i <= n; i++) {

int curr = prev1 + prev2;

prev2 = prev1;

prev1 = curr;

}

return prev1;

}

// 最长递增子序列（LeetCode 300）

public int lengthOfLIS(int[] nums) {

int[] dp = new int[nums.length];

Arrays.fill(dp, 1);

int maxLen = 1;

for (int i = 1; i < nums.length; i++) {

for (int j = 0; j < i; j++) {

if (nums[j] < nums[i]) {

dp[i] = Math.max(dp[i], dp[j] + 1);

}

}

maxLen = Math.max(maxLen, dp[i]);

}

return maxLen;

}

纯文本
**DP 解题步骤**：
1. 定义状态（dp[i] 的含义）
2. 推导状态转移方程
3. 初始化边界条件
4. 确定遍历顺序
5. 返回结果

---

### 9️⃣ Graph · 图
java

// 图的 DFS（邻接表）

void dfs(int node, boolean[] visited, List<List<Integer>> graph) {

visited[node] = true;

for (int neighbor : graph.get(node)) {

if (!visited[neighbor]) {

dfs(neighbor, visited, graph);

}

}

}

// 图的 BFS

void bfs(int start, List<List<Integer>> graph) {

boolean[] visited = new boolean[graph.size()];

Queue<Integer> queue = new LinkedList<>();

queue.offer(start);

visited[start] = true;

while (!queue.isEmpty()) {

int node = queue.poll();

for (int neighbor : graph.get(node)) {

if (!visited[neighbor]) {

visited[neighbor] = true;

queue.offer(neighbor);

}

}

}

}

纯文本
**常见题型**：
- 岛屿数量（LeetCode 200）
- 课程表（拓扑排序，LeetCode 207）
- 克隆图（LeetCode 133）
- 腐烂的橘子（LeetCode 994）

---

### 🔟 Sorting & Searching · 排序与搜索
java

// 快速排序

public void quickSort(int[] arr, int low, int high) {

if (low < high) {

int pivot = partition(arr, low, high);

quickSort(arr, low, pivot - 1);

quickSort(arr, pivot + 1, high);

}

}

private int partition(int[] arr, int low, int high) {

int pivot = arr[high];

int i = low - 1;

for (int j = low; j < high; j++) {

if (arr[j] < pivot) {

i++;

swap(arr, i, j);

}

}

swap(arr, i + 1, high);

return i + 1;

}

// 二分查找

public int binarySearch(int[] arr, int target) {

int left = 0, right = arr.length - 1;

while (left <= right) {

int mid = left + (right - left) / 2;

if (arr[mid] == target) return mid;

else if (arr[mid] < target) left = mid + 1;

else right = mid - 1;

}

return -1;

}

纯文本
---

## 📂 Code Examples · 代码示例

All runnable code examples are located in the [`src/`](./src/) directory:

| File | Description |
|------|-------------|
| `TwoPointersDemo.java` | Two sum, container with most water |
| `SlidingWindowDemo.java` | Longest substring without repeating characters |
| `LinkedListDemo.java` | Reverse linked list, cycle detection |
| `StackQueueDemo.java` | Valid parentheses, monotonic stack |
| `BinaryTreeDemo.java` | Traversals, max depth, BST validation |
| `HeapDemo.java` | Kth largest, top K frequent |
| `DynamicProgrammingDemo.java` | Fibonacci, climbing stairs, LIS |
| `GraphDemo.java` | DFS, BFS, island count |
| `SortSearchDemo.java` | Quick sort, binary search |

---

## ❓ Interview Tips · 面试技巧

### 解题步骤
1. **理解题意**：确认输入输出、边界条件、时间/空间要求。
2. **举例子**：用简单例子验证理解。
3. **暴力解法**：先给出最直接的解法，分析复杂度。
4. **优化**：逐步优化，解释每一步的 trade-off。
5. **写代码**：注意变量命名、边界检查、空值处理。
6. **测试**：用例子测试，包括边界情况。

### 常见陷阱
- 整数溢出（使用 long 或提前判断）
- 空指针（检查 null）
- 数组越界（检查索引范围）
- 死循环（确保循环条件能终止）

### 刷题策略
- **Easy 题**：掌握基础数据结构和常见模式。
- **Medium 题**：重点刷，覆盖大部分面试题。
- **Hard 题**：选择性刷，理解核心思路即可。
- **推荐平台**：LeetCode 热题 100、剑指 Offer、CodeTop 企业题库。

---

## 🇨🇳 中文说明

本目录覆盖了编码面试中最常见的数据结构和算法题型，包括数组、链表、栈、队列、二叉树、堆、动态规划、图、排序搜索等。每个主题都配有解题思路、Java 代码示例和时间复杂度分析。代码示例在 `src/` 目录下，可以直接编译运行。

---

*Practice makes perfect. Code every day.* 🧮