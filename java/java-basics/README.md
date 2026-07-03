# Java Basics ☕

> Core Java fundamentals for backend engineers (3–5 years experience).  
> Java 基础核心知识，适合快速复习和面试准备。

[![Java](https://img.shields.io/badge/Java-17%2B-orange)](https://openjdk.org/)

---

## 📖 Overview · 概览

This section covers the most essential Java fundamentals: syntax, OOP, exceptions, generics, annotations, reflection, enums, inner classes, string handling, and common utilities. Each topic includes concise explanations, code examples with Chinese comments, and typical interview questions with answers.

本章涵盖最核心的 Java 基础知识：语法、面向对象、异常、泛型、注解、反射、枚举、内部类、字符串处理和常用工具类。每个主题都包含简洁的说明、带中文注释的代码示例以及带答案的常见面试题。

---

## 🗂️ Topics · 主题速查

### 1️⃣ Basic Syntax · 基本语法
java

// 变量与数据类型

int age = 25;                    // 基本类型

String name = "Alice";           // 引用类型

final double PI = 3.14159;       // 常量

// 流程控制

if (age >= 18) {

System.out.println("Adult");

} else {

System.out.println("Minor");

}

// switch 表达式 (Java 14+)

String result = switch (age) {

case 18, 19, 20 -> "Young adult";

default -> "Other";

};

// 循环

for (int i = 0; i < 5; i++) {

System.out.println(i);

}

**注意事项**：
- Java 是强类型语言，所有变量必须先声明后使用。
- `switch` 表达式比传统 `switch` 语句更简洁，且不会穿透。

---

### 2️⃣ Object-Oriented Programming · 面向对象
java

// 封装

public class Person {

private String name;          // 私有字段

private int age;

// 构造方法
public Person(String name, int age) {
this.name = name;
this.age = age;
}

// Getter/Setter
public String getName() { return name; }
public void setName(String name) { this.name = name; }
}

// 继承

public class Student extends Person {

private String studentId;

public Student(String name, int age, String studentId) {
super(name, age);         // 调用父类构造器
this.studentId = studentId;
}
}

// 多态

Person p = new Student("Bob", 20, "S001");  // 向上转型

p.getName();                                 // 调用父类方法（实际执行子类覆盖的方法）

// 抽象类

abstract class Shape {

abstract double area();       // 抽象方法

}

// 接口

interface Drawable {

void draw();                  // 默认 public abstract

default void print() {        // 默认方法 (Java 8+)

System.out.println("Printing...");

}

}

---

### 3️⃣ Exception Handling · 异常处理
java

// try-catch-finally

try {

int result = 10 / 0;         // 抛出 ArithmeticException

} catch (ArithmeticException e) {

System.out.println("除数不能为零: " + e.getMessage());

} finally {

System.out.println("finally 块总会执行");

}

// try-with-resources (Java 7+)

try (BufferedReader br = new BufferedReader(new FileReader("test.txt"))) {

String line = br.readLine();

} catch (IOException e) {

e.printStackTrace();

}

**注意事项**：
- 受检异常（Checked Exception）必须处理或声明抛出；非受检异常（RuntimeException）可选处理。
- 不要在 finally 块中使用 return，会吞掉异常。

---

### 4️⃣ Generics · 泛型
java

// 泛型类

public class Box<T> {

private T content;

public void set(T content) { this.content = content; }

public T get() { return content; }

}

// 泛型方法

public static <T> T getMiddle(T... a) {

return a[a.length / 2];

}

// 类型擦除：运行时 T 被替换为 Object（或边界类型）

// 通配符

List<? extends Number> numbers = new ArrayList<Integer>();  // 上界通配符

List<? super Integer> integers = new ArrayList<Number>();   // 下界通配符

---

### 5️⃣ Annotations · 注解
java

// 自定义注解

@Retention(RetentionPolicy.RUNTIME)   // 运行时保留

@Target(ElementType.METHOD)           // 作用于方法

public @interface MyAnnotation {

String value() default "";

int count() default 1;

}

// 使用注解

public class Service {

@MyAnnotation(value = "hello", count = 3)

public void doSomething() {}

}

// 反射读取注解

Method method = Service.class.getMethod("doSomething");

MyAnnotation anno = method.getAnnotation(MyAnnotation.class);

System.out.println(anno.value());   // 输出 "hello"

---

### 6️⃣ Reflection · 反射
java

// 获取 Class 对象的三种方式

Class<?> clazz1 = String.class;

Class<?> clazz2 = "hello".getClass();

Class<?> clazz3 = Class.forName("java.lang.String");

// 创建实例

Object obj = clazz1.getDeclaredConstructor().newInstance();

// 访问私有字段

Field field = clazz1.getDeclaredField("value");  // String 内部的 char[]

field.setAccessible(true);                        // 绕过访问检查

char[] val = (char[]) field.get("hello");

// 动态代理

InvocationHandler handler = (proxy, method, args) -> {

System.out.println("Before method: " + method.getName());

return method.invoke(target, args);

};

SomeInterface proxy = (SomeInterface) Proxy.newProxyInstance(

classLoader, interfaces, handler);

**注意事项**：
- 反射性能较低，频繁调用时考虑缓存或使用 `MethodHandles`。
- `setAccessible(true)` 可能被安全管理器阻止。

---

### 7️⃣ Enums · 枚举
java

public enum Color {

RED, GREEN, BLUE;            // 简单枚举

// 带字段和方法的枚举
public enum Status {
PENDING(0), SUCCESS(1), FAILURE(-1);
private final int code;
Status(int code) { this.code = code; }
public int getCode() { return code; }
}
}

---

### 8️⃣ Inner Classes · 内部类
java

// 成员内部类

class Outer {

private int x = 10;

class Inner {

void print() { System.out.println(x); }  // 可以访问外部类的私有成员

}

}

// 静态内部类

static class StaticInner {

// 不能访问外部类的非静态成员

}

// 匿名内部类（常用于事件监听、线程）

Runnable r = new Runnable() {

@Override

public void run() {

System.out.println("Running");

}

};

---

### 9️⃣ String Handling · 字符串处理
java

String s1 = "hello";               // 字符串常量池

String s2 = new String("hello");   // 堆中创建新对象

String s3 = "he" + "llo";          // 编译期优化，指向常量池

// StringBuilder（线程不安全，速度快）

StringBuilder sb = new StringBuilder();

sb.append("hello").append(" world");

String result = sb.toString();

// StringBuffer（线程安全，速度稍慢）

StringBuffer buffer = new StringBuffer();

buffer.append("hello");

---

### 🔟 Common Utility Classes · 常用工具类
java

// Object

Object obj = new Object();

obj.equals(other);                 // 默认比较引用，建议重写

obj.hashCode();                    // 与 equals 一致

obj.toString();                    // 返回类名@哈希码

// Math

Math.max(a, b);

Math.min(a, b);

Math.random();                     // [0.0, 1.0)

// Arrays

int[] arr = {3, 1, 4, 1, 5};

Arrays.sort(arr);                  // 排序

int index = Arrays.binarySearch(arr, 4);  // 二分查找（需先排序）

String str = Arrays.toString(arr);

// Collections

List<String> list = new ArrayList<>();

Collections.sort(list);

Collections.reverse(list);

Collections.shuffle(list);

---

## 📂 Code Examples · 代码示例

All runnable code examples are located in the [`src/`](./src/) directory:

| File | Description |
|------|-------------|
| `BasicSyntaxDemo.java` | Variables, operators, control flow |
| `OOPDemo.java` | Classes, inheritance, polymorphism, abstract, interface |
| `ExceptionDemo.java` | Try-catch, try-with-resources, custom exception |
| `GenericsDemo.java` | Generic class, method, wildcard |
| `AnnotationDemo.java` | Custom annotation, reflection reading |
| `ReflectionDemo.java` | Class object, field access, dynamic proxy |
| `EnumDemo.java` | Simple enum, enum with fields |
| `InnerClassDemo.java` | Member, static, anonymous inner class |
| `StringDemo.java` | String pool, StringBuilder, StringBuffer |
| `UtilityDemo.java` | Object, Math, Arrays, Collections |

Each file contains `main` method so you can run directly: `javac src/*.java && java src.BasicSyntaxDemo`

---

## ❓ Interview Questions with Answers · 面试题（附答案）

### Java 基础
1. **面向对象三大特性是什么？请举例说明。**
    - **答**：封装（隐藏内部实现，提供公共方法）、继承（复用父类代码）、多态（同一接口不同实现）。例如：`Person` 类封装姓名年龄，`Student` 继承 `Person`，`Person p = new Student()` 实现多态。

2. **抽象类和接口的区别（Java 8 之后）？**
    - **答**：抽象类可以有构造方法、成员变量、具体方法和抽象方法；接口只能有常量、抽象方法、默认方法和静态方法（Java 8+）。一个类只能继承一个抽象类，但可以实现多个接口。抽象类用于“is-a”关系，接口用于“can-do”能力。

3. **重载（Overload）和重写（Override）的区别？**
    - **答**：重载发生在同一个类中，方法名相同参数列表不同，与返回值无关，编译时多态；重写发生在父子类中，方法签名完全相同，运行时多态。重写时不能降低访问权限，不能抛出更宽泛的异常。

4. **`==` 和 `equals()` 的区别？**
    - **答**：`==` 比较基本类型时比较值，比较引用类型时比较内存地址；`equals()` 是 Object 的方法，默认比较引用，但通常被重写为比较内容（如 String、Integer）。

5. **`final` 关键字的作用（修饰类、方法、变量）？**
    - **答**：`final` 修饰类表示该类不能被继承；修饰方法表示该方法不能被重写；修饰变量表示该变量是常量（基本类型值不变，引用类型引用不变）。

### 异常
6. **受检异常和非受检异常的区别？列举常见的 RuntimeException。**
    - **答**：受检异常（Checked Exception）必须显式捕获或声明抛出，如 `IOException`、`SQLException`；非受检异常（RuntimeException）可以不处理，如 `NullPointerException`、`ArrayIndexOutOfBoundsException`、`IllegalArgumentException`。

7. **`throw` 和 `throws` 的区别？**
    - **答**：`throw` 用于在方法体内抛出一个异常对象；`throws` 用在方法声明上，表示该方法可能抛出哪些异常，交给调用者处理。

8. **如何自定义异常？**
    - **答**：继承 `Exception`（受检）或 `RuntimeException`（非受检），提供构造方法。例如：`class MyException extends Exception { public MyException(String msg) { super(msg); } }`。

### 泛型
9. **什么是类型擦除？对泛型有什么影响？**
    - **答**：类型擦除是指 Java 编译器在编译时将泛型类型参数替换为其上限（如 `T` 变为 `Object`），并在必要时插入强制类型转换。影响：运行时无法获取泛型的具体类型，不能创建泛型数组，不能使用 `instanceof` 判断泛型类型。

10. **`List<? extends T>` 和 `List<? super T>` 的区别？**
    - **答**：`? extends T` 表示列表元素是 T 或 T 的子类，只能读取（get 返回 T），不能写入（add 不允许，除非 null）；`? super T` 表示列表元素是 T 或 T 的父类，可以写入 T 或子类（add 允许），但读取时只能赋给 Object。

### 注解与反射
11. **注解的保留策略有哪些？各自用途？**
    - **答**：`RetentionPolicy.SOURCE`（源码级别，编译后丢弃，如 `@Override`）、`CLASS`（编译到 class 文件，但运行时不可见）、`RUNTIME`（运行时可见，可通过反射读取，如 `@Autowired`）。

12. **反射的优缺点？什么时候使用反射？**
    - **答**：优点：运行时动态创建对象、访问私有成员、实现框架（Spring、MyBatis）。缺点：性能较低（比直接调用慢）、破坏封装、可能带来安全问题。适用于框架开发、IDE 工具、序列化等需要动态操作的场景。

13. **JDK 动态代理和 CGLIB 代理的区别？**
    - **答**：JDK 动态代理要求目标对象实现接口，基于 `InvocationHandler` 和 `Proxy` 类；CGLIB 代理通过继承目标类生成子类，不需要接口。Spring AOP 默认使用 JDK 动态代理，如果目标类没有实现接口则使用 CGLIB。

### 枚举与内部类
14. **枚举可以实现接口吗？可以继承类吗？**
    - **答**：枚举可以实现接口（enum 可以 implements），但不能继承类（因为枚举隐式继承 `java.lang.Enum`）。

15. **为什么匿名内部类访问外部局部变量时要求变量是 `final` 或 effectively final？**
    - **答**：因为匿名内部类会复制外部局部变量的副本，为了保证内外变量一致，Java 要求该变量不可变（final 或 effectively final），否则可能出现数据不一致。

### 字符串
16. **`String` 为什么设计成不可变的？**
    - **答**：① 字符串常量池可以共享，节省内存；② 安全性（如网络连接、文件路径等参数不会被篡改）；③ 线程安全；④ 方便 hashCode 缓存（String 的 hashCode 只计算一次）。

17. **`String`, `StringBuilder`, `StringBuffer` 的区别和适用场景？**
    - **答**：`String` 不可变，适合少量字符串操作；`StringBuilder` 可变、线程不安全，适合单线程大量拼接（性能最好）；`StringBuffer` 可变、线程安全（方法加 synchronized），适合多线程环境。

### 工具类
18. **`hashCode()` 和 `equals()` 的约定是什么？**
    - **答**：如果两个对象 `equals()` 相等，则它们的 `hashCode()` 必须相等；反过来不要求（hashCode 相等不一定 equals 相等）。重写 `equals()` 时必须重写 `hashCode()`，否则会导致 HashMap/HashSet 等无法正常工作。

19. **`Arrays.sort()` 底层使用什么排序算法？**
    - **答**：对于基本类型数组，使用 Dual-Pivot QuickSort（双轴快速排序）；对于对象数组，使用 TimSort（归并排序的优化版本，稳定排序）。

---

## 🇨🇳 中文说明

本目录覆盖了 Java 基础的所有核心知识点，每个主题都配有带中文注释的代码示例和带答案的常见面试题。如果你有一年多没写 Java，建议从基本语法开始，依次复习面向对象、异常、泛型、注解反射等，最后通过面试题检验掌握程度。  
代码示例在 `src/` 目录下，可以直接编译运行。

---