# Lambda & Stream 🌀

> Java lambda expressions and Stream API for backend engineers (3–5 years experience).  
> Java Lambda 表达式与 Stream API 核心知识，面试高频考点。

[![Java](https://img.shields.io/badge/Java-17%2B-orange)](https://openjdk.org/)

---

## 📖 Overview · 概览

This section covers Java lambda expressions, functional interfaces, method references, and the Stream API. These features enable functional-style programming in Java, making code more concise, readable, and parallelizable. Each topic includes code examples with Chinese comments and common interview questions with answers.

本章涵盖 Java Lambda 表达式、函数式接口、方法引用和 Stream API。这些特性使 Java 支持函数式编程风格，让代码更简洁、易读且易于并行化。每个主题都包含带中文注释的代码示例和带答案的常见面试题。

---

## 🗂️ Topics · 主题速查

### 1️⃣ Lambda Expressions · Lambda 表达式
java

// 基本语法：(parameters) -> expression 或 (parameters) -> { statements; }

// 无参数

Runnable r = () -> System.out.println("Hello");

// 单参数（可省略括号）

Consumer<String> consumer = s -> System.out.println(s);

// 多参数

Comparator<Integer> comparator = (a, b) -> a - b;

// 多行语句

BiFunction<Integer, Integer, Integer> func = (a, b) -> {

int sum = a + b;

return sum * 2;

};

**注意事项**：
- Lambda 表达式本质上是函数式接口的匿名实现。
- 目标类型必须是函数式接口（只有一个抽象方法的接口）。

---

### 2️⃣ Functional Interfaces · 函数式接口

Java 8 内置的核心函数式接口（都在 `java.util.function` 包下）：

| Interface | Method | Description · 说明 |
|-----------|--------|--------------------|
| `Predicate<T>` | `boolean test(T t)` | 断言，返回 boolean |
| `Consumer<T>` | `void accept(T t)` | 消费一个参数，无返回值 |
| `Function<T, R>` | `R apply(T t)` | 接收 T 返回 R |
| `Supplier<T>` | `T get()` | 提供 T 类型的结果 |
| `UnaryOperator<T>` | `T apply(T t)` | 一元操作，T → T |
| `BinaryOperator<T>` | `T apply(T t1, T t2)` | 二元操作，(T, T) → T |
java

// Predicate

Predicate<String> isEmpty = s -> s.isEmpty();

Predicate<String> isNotEmpty = isEmpty.negate();  // 取反

Predicate<String> combined = isEmpty.or(s -> s.length() > 10);

// Consumer

Consumer<String> printer = s -> System.out.println(s);

Consumer<String> logger = s -> System.out.println("[LOG] " + s);

printer.andThen(logger).accept("Hello");  // 先打印，再日志

// Function

Function<String, Integer> toLength = s -> s.length();

Function<Integer, String> toString = i -> "Length: " + i;

Function<String, String> composed = toLength.andThen(toString);

System.out.println(composed.apply("Hello"));  // Length: 5

// Supplier

Supplier<Double> random = () -> Math.random();

---

### 3️⃣ Method References · 方法引用
java

// 四种形式

// 1. 静态方法引用：ClassName::staticMethod

Function<String, Integer> parseInt = Integer::parseInt;

// 2. 实例方法引用（特定对象）：instance::method

String str = "hello";

Supplier<Integer> length = str::length;

// 3. 实例方法引用（任意对象）：ClassName::method

Function<String, Integer> stringLength = String::length;

// 4. 构造方法引用：ClassName::new

Supplier<List<String>> listCreator = ArrayList::new;

Function<String, StringBuilder> sbCreator = StringBuilder::new;

---

### 4️⃣ Stream API · 流式 API

#### 创建 Stream
java

// 从集合创建

List<String> list = Arrays.asList("a", "b", "c");

Stream<String> stream = list.stream();

Stream<String> parallelStream = list.parallelStream();

// 从数组创建

Stream<Integer> arrayStream = Arrays.stream(new Integer[]{1, 2, 3});

// 直接创建

Stream<String> of = Stream.of("a", "b", "c");

Stream<Integer> iterate = Stream.iterate(0, n -> n + 2).limit(10);

Stream<Double> generate = Stream.generate(Math::random).limit(5);

// 从文件

Stream<String> lines = Files.lines(Paths.get("file.txt"));

#### Intermediate Operations · 中间操作
java

// filter：过滤

Stream.of(1, 2, 3, 4, 5)

.filter(n -> n % 2 == 0)      // [2, 4]

// map：映射

Stream.of("a", "bc", "def")

.map(String::length)           // [1, 2, 3]

// flatMap：扁平化映射

List<List<String>> nested = Arrays.asList(

Arrays.asList("a", "b"),

Arrays.asList("c", "d")

);

nested.stream()

.flatMap(List::stream)         // ["a", "b", "c", "d"]

// distinct：去重

Stream.of(1, 2, 2, 3, 3, 3).distinct()  // [1, 2, 3]

// sorted：排序

Stream.of(3, 1, 2).sorted()                // [1, 2, 3]

Stream.of(3, 1, 2).sorted(Comparator.reverseOrder())  // [3, 2, 1]

// peek：调试（消费但不改变元素）

Stream.of("a", "b")

.peek(e -> System.out.println("Processing: " + e))

.collect(Collectors.toList());

// limit / skip：限制/跳过

Stream.of(1, 2, 3, 4, 5).limit(3)   // [1, 2, 3]

Stream.of(1, 2, 3, 4, 5).skip(2)    // [3, 4, 5]

#### Terminal Operations · 终端操作
java

// forEach：遍历

Stream.of("a", "b").forEach(System.out::println);

// collect：收集

List<String> list = stream.collect(Collectors.toList());

Set<String> set = stream.collect(Collectors.toSet());

Map<Integer, String> map = stream.collect(Collectors.toMap(

String::length, Function.identity(), (a, b) -> a  // 处理重复 key

));

String joined = stream.collect(Collectors.joining(", "));

// toList (Java 16+)

List<String> list16 = stream.toList();  // 不可变列表

// reduce：归约

Optional<Integer> sum = Stream.of(1, 2, 3).reduce(Integer::sum);

int product = Stream.of(1, 2, 3).reduce(1, (a, b) -> a * b);  // 有初始值

// count：计数

long count = stream.count();

// anyMatch / allMatch / noneMatch：匹配

boolean hasEven = Stream.of(1, 2, 3).anyMatch(n -> n % 2 == 0);

boolean allPositive = Stream.of(1, 2, 3).allMatch(n -> n > 0);

// findFirst / findAny：查找

Optional<Integer> first = stream.findFirst();

Optional<Integer> any = stream.findAny();  // 并行流中可能更快

// min / max：最值

Optional<Integer> min = stream.min(Integer::compareTo);

Optional<Integer> max = stream.max(Integer::compareTo);

---

### 5️⃣ Collectors · 收集器
java

// 分组

Map<Integer, List<String>> byLength = stream.collect(

Collectors.groupingBy(String::length));

// 分区

Map<Boolean, List<Integer>> evenOdd = Stream.of(1, 2, 3, 4).collect(

Collectors.partitioningBy(n -> n % 2 == 0));

// 下游收集器

Map<Integer, Long> countByLength = stream.collect(

Collectors.groupingBy(String::length, Collectors.counting()));

Map<Integer, Set<String>> setByLength = stream.collect(

Collectors.groupingBy(String::length, Collectors.toSet()));

// summarizing：统计摘要

IntSummaryStatistics stats = Stream.of(1, 2, 3, 4, 5)

.collect(Collectors.summarizingInt(Integer::intValue));

System.out.println(stats.getSum());     // 15

System.out.println(stats.getAverage()); // 3.0

---

### 6️⃣ Optional · 可选值
java

// 创建

Optional<String> empty = Optional.empty();

Optional<String> nonNull = Optional.of("value");     // 非空，null 会抛 NPE

Optional<String> nullable = Optional.ofNullable(null); // 可为 null

// 使用

String result = optional.orElse("default");           // 有值返回，无值返回默认

String result2 = optional.orElseGet(() -> computeDefault()); // 延迟计算默认值

String result3 = optional.orElseThrow(() -> new IllegalArgumentException("No value"));

// 转换

Optional<Integer> length = optional.map(String::length);

Optional<String> upper = optional.filter(s -> s.length() > 3);

// ifPresent

optional.ifPresent(System.out::println);

optional.ifPresentOrElse(

val -> System.out.println("Value: " + val),

() -> System.out.println("No value")

);

**注意事项**：
- `Optional` 不应该用作字段类型或方法参数，只适合作为返回值。
- `Optional` 本身是可序列化的，但序列化后可能失去语义。

---

### 7️⃣ Practical Examples · 实战示例
java

// 1. 从列表中筛选出符合条件的元素

List<String> names = Arrays.asList("Alice", "Bob", "Charlie", "David");

List<String> filtered = names.stream()

.filter(name -> name.startsWith("A") || name.startsWith("C"))

.map(String::toUpperCase)

.sorted()

.collect(Collectors.toList());

// 结果: ["ALICE", "CHARLIE"]

// 2. 统计单词频率

String text = "hello world hello java world";

Map<String, Long> wordCount = Arrays.stream(text.split(" "))

.collect(Collectors.groupingBy(Function.identity(), Collectors.counting()));

// 结果: {hello=2, world=2, java=1}

// 3. 并行流处理大数据

long sum = LongStream.rangeClosed(1, 10_000_000)

.parallel()

.sum();

// 4. 嵌套对象处理

List<Order> orders = getOrders();

Map<String, Double> totalByCustomer = orders.stream()

.collect(Collectors.groupingBy(

Order::getCustomerName,

Collectors.summingDouble(Order::getAmount)

));

---

## 📂 Code Examples · 代码示例

All runnable code examples are located in the [`src/`](./src/) directory:

| File | Description |
|------|-------------|
| `LambdaDemo.java` | Lambda 表达式、函数式接口、方法引用 |
| `StreamBasicsDemo.java` | 创建 Stream、中间操作、终端操作 |
| `CollectorsDemo.java` | groupingBy, partitioningBy, summarizing |
| `OptionalDemo.java` | Optional 创建、转换、使用 |
| `ParallelStreamDemo.java` | 并行流注意事项 |

---

## ❓ Interview Questions with Answers · 面试题（附答案）

### Lambda
1. **Lambda 表达式和匿名内部类的区别？**
    - **答**：Lambda 更简洁，只能用于函数式接口；匿名内部类可以是任何接口或抽象类。Lambda 编译后生成 invokedynamic 指令，匿名内部类编译后生成单独的 class 文件。Lambda 不能访问非 effectively final 的局部变量（与匿名内部类相同）。

2. **什么是函数式接口？有哪些内置的函数式接口？**
    - **答**：只有一个抽象方法的接口（可以有默认方法和静态方法）。内置接口：Predicate、Consumer、Function、Supplier、UnaryOperator、BinaryOperator。

### Stream
3. **Stream 的中间操作和终端操作的区别？**
    - **答**：中间操作返回一个新的 Stream，惰性执行（只在终端操作时触发）；终端操作触发实际计算，消费 Stream 后不能再使用。

4. **map 和 flatMap 的区别？**
    - **答**：map 是一对一映射，每个元素映射为一个新元素；flatMap 是一对多映射，将每个元素映射为一个 Stream，然后将所有 Stream 扁平化为一个 Stream。

5. **Stream 的并行流如何工作？什么情况下应该使用？**
    - **答**：并行流使用 ForkJoinPool 将任务拆分为子任务并行执行。适合数据量大、元素间无依赖、处理耗时的场景。不适合有状态操作（如 limit、findFirst 依赖顺序）或线程不安全的操作。

6. **Stream 和集合的区别？**
    - **答**：集合存储数据，可以多次遍历；Stream 是一次性的管道，只能消费一次。集合关注数据的存储，Stream 关注数据的计算。

### Optional
7. **Optional 的目的是什么？应该怎么用？**
    - **答**：Optional 旨在避免 NullPointerException，明确表示值可能缺失。应作为方法返回值类型，告知调用者需要处理空值。不应作为字段或方法参数。

8. **Optional 的 orElse 和 orElseGet 的区别？**
    - **答**：orElse 无论 Optional 是否有值都会计算默认值；orElseGet 只有在 Optional 为空时才计算默认值（延迟计算）。如果默认值计算开销大，应使用 orElseGet。

### 其他
9. **方法引用有哪几种形式？**
    - **答**：四种：静态方法引用（`ClassName::staticMethod`）、特定对象的实例方法引用（`instance::method`）、任意对象的实例方法引用（`ClassName::method`）、构造方法引用（`ClassName::new`）。

10. **Collectors.groupingBy 和 partitioningBy 的区别？**
    - **答**：groupingBy 根据任意分类函数分组，返回 `Map<K, List<V>>`；partitioningBy 根据 Predicate 分为两组（true/false），返回 `Map<Boolean, List<V>>`。

---

## 🇨🇳 中文说明

本目录覆盖了 Java Lambda 表达式和 Stream API 的核心知识，包括函数式接口、方法引用、Stream 的创建/中间操作/终端操作、Collectors、Optional 等。每个主题都配有带中文注释的代码示例和带答案的面试题。代码示例在 `src/` 目录下，可以直接编译运行。

---

*Functional programming in Java: write less, do more.* 🌀