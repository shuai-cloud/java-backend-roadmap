# Design Patterns 🏗️

> Java design patterns for backend engineers (3–5 years experience).  
> Java 设计模式核心知识，面试高频考点。

[![Java](https://img.shields.io/badge/Java-17%2B-orange)](https://openjdk.org/)

---

## 📖 Overview · 概览

This section covers the most commonly used design patterns in Java backend development: creational, structural, and behavioral patterns. Understanding these patterns helps you write maintainable, reusable, and flexible code. Each pattern includes a real-world scenario, code example with Chinese comments, and common interview questions with answers.

本章涵盖 Java 后端开发中最常用的设计模式：创建型、结构型和行为型。理解这些模式有助于编写可维护、可复用和灵活的代码。每个模式都包含实际场景、带中文注释的代码示例和带答案的常见面试题。

---

## 🗂️ Topics · 主题速查

### 1️⃣ Creational Patterns · 创建型模式

#### Singleton · 单例模式
java

// 饿汉式（线程安全，类加载时创建）

public class EagerSingleton {

private static final EagerSingleton INSTANCE = new EagerSingleton();

private EagerSingleton() {}

public static EagerSingleton getInstance() { return INSTANCE; }

}

// 懒汉式（双重检查锁定，推荐）

public class LazySingleton {

private static volatile LazySingleton instance;  // volatile 防止指令重排

private LazySingleton() {}

public static LazySingleton getInstance() {

if (instance == null) {

synchronized (LazySingleton.class) {

if (instance == null) {

instance = new LazySingleton();

}

}

}

return instance;

}

}

// 静态内部类（推荐，延迟加载，线程安全）

public class HolderSingleton {

private HolderSingleton() {}

private static class Holder {

static final HolderSingleton INSTANCE = new HolderSingleton();

}

public static HolderSingleton getInstance() { return Holder.INSTANCE; }

}

// 枚举（最简洁，防反射攻击）

public enum EnumSingleton {

INSTANCE;

public void doSomething() {}

}

**注意事项**：
- 单例必须保证构造方法私有。
- 需要考虑序列化（实现 `readResolve` 方法）和反射攻击。
- 枚举实现天然防御反射和序列化问题。

---

#### Factory Method · 工厂方法
java

// 产品接口

interface Product {

void use();

}

// 具体产品

class ConcreteProductA implements Product {

public void use() { System.out.println("Using Product A"); }

}

class ConcreteProductB implements Product {

public void use() { System.out.println("Using Product B"); }

}

// 工厂接口

interface Factory {

Product createProduct();

}

// 具体工厂

class FactoryA implements Factory {

public Product createProduct() { return new ConcreteProductA(); }

}

class FactoryB implements Factory {

public Product createProduct() { return new ConcreteProductB(); }

}

// 使用

Factory factory = new FactoryA();

Product product = factory.createProduct();

product.use();

---

#### Abstract Factory · 抽象工厂
java

// 产品族：Button 和 Checkbox

interface Button { void render(); }

interface Checkbox { void check(); }

// Windows 风格

class WinButton implements Button { public void render() { System.out.println("Win Button"); } }

class WinCheckbox implements Checkbox { public void check() { System.out.println("Win Checkbox"); } }

// Mac 风格

class MacButton implements Button { public void render() { System.out.println("Mac Button"); } }

class MacCheckbox implements Checkbox { public void check() { System.out.println("Mac Checkbox"); } }

// 抽象工厂

interface GUIFactory {

Button createButton();

Checkbox createCheckbox();

}

class WinFactory implements GUIFactory {

public Button createButton() { return new WinButton(); }

public Checkbox createCheckbox() { return new WinCheckbox(); }

}

class MacFactory implements GUIFactory {

public Button createButton() { return new MacButton(); }

public Checkbox createCheckbox() { return new MacCheckbox(); }

}

---

#### Builder · 建造者模式
java

// 复杂对象

public class Computer {

private String cpu;

private String ram;

private String storage;

private boolean graphicsCardEnabled;

private Computer(Builder builder) {
this.cpu = builder.cpu;
this.ram = builder.ram;
this.storage = builder.storage;
this.graphicsCardEnabled = builder.graphicsCardEnabled;
}

public static class Builder {
private String cpu;
private String ram;
private String storage;
private boolean graphicsCardEnabled = false;

    public Builder(String cpu, String ram) {  // 必需参数
        this.cpu = cpu;
        this.ram = ram;
    }
    public Builder storage(String storage) { this.storage = storage; return this; }
    public Builder graphicsCardEnabled(boolean value) { this.graphicsCardEnabled = value; return this; }
    public Computer build() { return new Computer(this); }
}
}

// 使用

Computer computer = new Computer.Builder("Intel i7", "16GB")

.storage("512GB SSD")

.graphicsCardEnabled(true)

.build();

---

### 2️⃣ Structural Patterns · 结构型模式

#### Adapter · 适配器模式
java

// 目标接口

interface MediaPlayer {

void play(String audioType, String fileName);

}

// 适配者

class AdvancedMediaPlayer {

public void playVlc(String fileName) { System.out.println("Playing vlc: " + fileName); }

public void playMp4(String fileName) { System.out.println("Playing mp4: " + fileName); }

}

// 适配器

class MediaAdapter implements MediaPlayer {

private AdvancedMediaPlayer advancedPlayer = new AdvancedMediaPlayer();

@Override
public void play(String audioType, String fileName) {
if ("vlc".equalsIgnoreCase(audioType)) {
advancedPlayer.playVlc(fileName);
} else if ("mp4".equalsIgnoreCase(audioType)) {
advancedPlayer.playMp4(fileName);
}
}
}

---

#### Proxy · 代理模式
java

// 主题接口

interface Image {

void display();

}

// 真实主题

class RealImage implements Image {

private String fileName;

public RealImage(String fileName) { this.fileName = fileName; loadFromDisk(); }

private void loadFromDisk() { System.out.println("Loading " + fileName); }

public void display() { System.out.println("Displaying " + fileName); }

}

// 代理（延迟加载）

class ProxyImage implements Image {

private RealImage realImage;

private String fileName;

public ProxyImage(String fileName) { this.fileName = fileName; }

public void display() {

if (realImage == null) {

realImage = new RealImage(fileName);

}

realImage.display();

}

}

// 动态代理（JDK）

InvocationHandler handler = (proxy, method, args) -> {

System.out.println("Before method: " + method.getName());

Object result = method.invoke(target, args);

System.out.println("After method");

return result;

};

Image proxy = (Image) Proxy.newProxyInstance(

target.getClass().getClassLoader(),

target.getClass().getInterfaces(),

handler);

---

#### Decorator · 装饰器模式
java

// 组件接口

interface Coffee {

double cost();

String description();

}

// 具体组件

class SimpleCoffee implements Coffee {

public double cost() { return 5.0; }

public String description() { return "Simple coffee"; }

}

// 装饰器基类

abstract class CoffeeDecorator implements Coffee {

protected Coffee decoratedCoffee;

public CoffeeDecorator(Coffee coffee) { this.decoratedCoffee = coffee; }

public double cost() { return decoratedCoffee.cost(); }

public String description() { return decoratedCoffee.description(); }

}

// 具体装饰器

class MilkDecorator extends CoffeeDecorator {

public MilkDecorator(Coffee coffee) { super(coffee); }

public double cost() { return super.cost() + 2.0; }

public String description() { return super.description() + ", milk"; }

}

class SugarDecorator extends CoffeeDecorator {

public SugarDecorator(Coffee coffee) { super(coffee); }

public double cost() { return super.cost() + 1.0; }

public String description() { return super.description() + ", sugar"; }

}

// 使用

Coffee coffee = new SugarDecorator(new MilkDecorator(new SimpleCoffee()));

System.out.println(coffee.description() + " costs $" + coffee.cost());

// 输出: Simple coffee, milk, sugar costs $8.0

---

### 3️⃣ Behavioral Patterns · 行为型模式

#### Strategy · 策略模式
java

// 策略接口

interface PaymentStrategy {

void pay(double amount);

}

// 具体策略

class CreditCardPayment implements PaymentStrategy {

private String cardNumber;

public CreditCardPayment(String cardNumber) { this.cardNumber = cardNumber; }

public void pay(double amount) { System.out.println("Paid " + amount + " via credit card"); }

}

class PayPalPayment implements PaymentStrategy {

private String email;

public PayPalPayment(String email) { this.email = email; }

public void pay(double amount) { System.out.println("Paid " + amount + " via PayPal"); }

}

// 上下文

class ShoppingCart {

private PaymentStrategy paymentStrategy;

public void setPaymentStrategy(PaymentStrategy strategy) { this.paymentStrategy = strategy; }

public void checkout(double amount) { paymentStrategy.pay(amount); }

}

// 使用

ShoppingCart cart = new ShoppingCart();

cart.setPaymentStrategy(new CreditCardPayment("1234-5678"));

cart.checkout(100.0);

---

#### Observer · 观察者模式
java

// 观察者接口

interface Observer {

void update(String message);

}

// 主题

class Subject {

private List<Observer> observers = new ArrayList<>();

public void attach(Observer observer) { observers.add(observer); }

public void detach(Observer observer) { observers.remove(observer); }

public void notifyObservers(String message) {

for (Observer obs : observers) {

obs.update(message);

}

}

}

// 具体观察者

class EmailNotifier implements Observer {

public void update(String message) { System.out.println("Email: " + message); }

}

class SMSNotifier implements Observer {

public void update(String message) { System.out.println("SMS: " + message); }

}

// 使用

Subject subject = new Subject();

subject.attach(new EmailNotifier());

subject.attach(new SMSNotifier());

subject.notifyObservers("Order shipped");

---

#### Template Method · 模板方法模式
java

// 抽象类定义算法骨架

abstract class DataProcessor {

public final void process() {        // 模板方法，final 防止子类重写

readData();

processData();

writeData();

}

abstract void readData();

abstract void processData();

void writeData() {                   // 可选钩子

System.out.println("Writing to database");

}

}

class CSVProcessor extends DataProcessor {

void readData() { System.out.println("Reading CSV"); }

void processData() { System.out.println("Processing CSV data"); }

}

class JSONProcessor extends DataProcessor {

void readData() { System.out.println("Reading JSON"); }

void processData() { System.out.println("Processing JSON data"); }

}

---

## 📂 Code Examples · 代码示例

All runnable code examples are located in the [`src/`](./src/) directory:

| File | Description |
|------|-------------|
| `SingletonDemo.java` | 四种单例实现 |
| `FactoryDemo.java` | 工厂方法模式 |
| `AbstractFactoryDemo.java` | 抽象工厂模式 |
| `BuilderDemo.java` | 建造者模式 |
| `AdapterDemo.java` | 适配器模式 |
| `ProxyDemo.java` | 静态代理和动态代理 |
| `DecoratorDemo.java` | 装饰器模式 |
| `StrategyDemo.java` | 策略模式 |
| `ObserverDemo.java` | 观察者模式 |
| `TemplateMethodDemo.java` | 模板方法模式 |

---

## ❓ Interview Questions with Answers · 面试题（附答案）

### 创建型
1. **单例模式的实现方式有哪些？哪种最推荐？**
    - **答**：饿汉式、懒汉式（双重检查锁定）、静态内部类、枚举。枚举最推荐，因为 JVM 保证线程安全，且天然防御反射和序列化攻击。

2. **双重检查锁定为什么要用 volatile？**
    - **答**：防止指令重排。`instance = new LazySingleton()` 在字节码层面分为三步：① 分配内存；② 初始化对象；③ 将引用指向内存地址。如果没有 volatile，步骤 ② 和 ③ 可能被重排，导致另一个线程拿到未初始化的对象。

3. **工厂方法模式和抽象工厂模式的区别？**
    - **答**：工厂方法模式针对单一产品等级结构，一个工厂创建一个产品；抽象工厂模式针对产品族，一个工厂创建一系列相关产品。抽象工厂是工厂方法的升级版。

### 结构型
4. **代理模式和装饰器模式的区别？**
    - **答**：代理模式控制对对象的访问（如延迟加载、权限控制），通常在编译时不知道具体代理逻辑；装饰器模式动态地为对象添加功能，客户端可以灵活组合装饰器。代理通常由代理类创建目标对象，装饰器由客户端传入目标对象。

5. **JDK 动态代理和 CGLIB 代理的区别？**
    - **答**：JDK 动态代理要求目标对象实现接口，基于 InvocationHandler 和 Proxy；CGLIB 通过继承目标类生成子类，不需要接口。Spring AOP 默认使用 JDK 动态代理，如果目标类没有接口则使用 CGLIB。

6. **适配器模式和桥接模式的区别？**
    - **答**：适配器模式用于让不兼容的接口协同工作，重在转换；桥接模式用于将抽象部分与实现部分分离，使它们可以独立变化，重在解耦。

### 行为型
7. **策略模式和状态模式的区别？**
    - **答**：策略模式中，策略由客户端选择和切换，对象的行为可以完全替换；状态模式中，状态的切换由对象内部管理，不同状态下的行为不同。策略模式强调算法族，状态模式强调状态驱动的行为变化。

8. **观察者模式的应用场景？**
    - **答**：事件驱动系统（如 GUI 按钮点击）、发布-订阅系统（如消息队列）、Spring 的事件机制（ApplicationEvent + ApplicationListener）。

9. **模板方法模式中钩子方法的作用？**
    - **答**：钩子方法是在模板方法中定义的默认方法，子类可以选择性地覆盖。例如 `writeData()` 默认写入数据库，子类可以覆盖为写入文件或控制台。

### 原则
10. **设计模式的六大原则？**
    - **答**：① 开闭原则（对扩展开放，对修改关闭）；② 里氏替换原则（子类可以替换父类）；③ 依赖倒置原则（依赖抽象，不依赖具体）；④ 接口隔离原则（接口尽量小而专）；⑤ 迪米特法则（最少知道原则）；⑥ 单一职责原则（一个类只负责一个职责）。

---

## 🇨🇳 中文说明

本目录覆盖了 Java 后端开发中最常用的设计模式，包括单例、工厂、建造者、适配器、代理、装饰器、策略、观察者、模板方法等。每个模式都配有实际场景、带中文注释的代码示例和带答案的面试题。代码示例在 `src/` 目录下，可以直接编译运行。

---

*Design patterns are proven solutions to recurring problems.* 🏗️