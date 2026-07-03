# I/O & NIO 📂

> Java I/O and NIO for backend engineers (3–5 years experience).  
> Java I/O 与 NIO 核心知识，面试高频考点。

[![Java](https://img.shields.io/badge/Java-17%2B-orange)](https://openjdk.org/)

---

## 📖 Overview · 概览

This section covers Java I/O (InputStream/OutputStream, Reader/Writer) and NIO (Channel, Buffer, Selector). Understanding the differences between blocking and non-blocking I/O, buffered streams, and memory-mapped files is crucial for building high-performance applications. Each topic includes code examples with Chinese comments and common interview questions with answers.

本章涵盖 Java I/O（InputStream/OutputStream、Reader/Writer）和 NIO（Channel、Buffer、Selector）。理解阻塞与非阻塞 I/O、缓冲流、内存映射文件对于构建高性能应用至关重要。每个主题都包含带中文注释的代码示例和带答案的常见面试题。

---

## 🗂️ Topics · 主题速查

### 1️⃣ I/O Stream Architecture · I/O 流体系

字节流 (Byte Streams)

├── InputStream (抽象基类)

│   ├── FileInputStream

│   ├── BufferedInputStream

│   ├── DataInputStream

│   └── ObjectInputStream

└── OutputStream (抽象基类)

├── FileOutputStream

├── BufferedOutputStream

├── DataOutputStream

└── ObjectOutputStream

字符流 (Character Streams)

├── Reader (抽象基类)

│   ├── FileReader

│   ├── BufferedReader

│   └── InputStreamReader (字节->字符桥梁)

└── Writer (抽象基类)

├── FileWriter

├── BufferedWriter

└── OutputStreamWriter (字符->字节桥梁)

---

### 2️⃣ Byte Streams · 字节流

java

// 文件复制（字节流）

try (FileInputStream fis = new FileInputStream("source.dat");

FileOutputStream fos = new FileOutputStream("dest.dat")) {

byte[] buffer = new byte[8192];  // 8KB 缓冲区

int bytesRead;

while ((bytesRead = fis.read(buffer)) != -1) {

fos.write(buffer, 0, bytesRead);

}

}

// 缓冲流（性能更好）

try (BufferedInputStream bis = new BufferedInputStream(new FileInputStream("source.dat"));

BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream("dest.dat"))) {

byte[] buffer = new byte[8192];

int bytesRead;

while ((bytesRead = bis.read(buffer)) != -1) {

bos.write(buffer, 0, bytesRead);

}

}

**注意事项**：
- 字节流适合处理二进制文件（图片、视频、压缩包）。
- 缓冲流内部维护 8KB 缓冲区，减少系统调用次数，显著提升性能。

---

### 3️⃣ Character Streams · 字符流

java

// 文本文件读取（字符流）

try (BufferedReader reader = new BufferedReader(new FileReader("input.txt"))) {

String line;

while ((line = reader.readLine()) != null) {

System.out.println(line);

}

}

// 文本文件写入

try (BufferedWriter writer = new BufferedWriter(new FileWriter("output.txt"))) {

writer.write("Hello, World!");

writer.newLine();

writer.write("Second line");

}

// 指定编码（使用 InputStreamReader/OutputStreamWriter）

try (BufferedReader reader = new BufferedReader(

new InputStreamReader(new FileInputStream("input.txt"), StandardCharsets.UTF_8));

BufferedWriter writer = new BufferedWriter(

new OutputStreamWriter(new FileOutputStream("output.txt"), StandardCharsets.UTF_8))) {

// 读写操作

}

**注意事项**：
- 字符流适合处理文本文件，自动处理字符编码。
- 使用 `InputStreamReader` / `OutputStreamWriter` 可以指定编码，避免乱码。

---

### 4️⃣ Object Streams · 对象流

java

// 序列化

@Data

class User implements Serializable {

private static final long serialVersionUID = 1L;  // 版本号

private String name;

private transient int age;  // transient 字段不会被序列化

}

// 写入对象

try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream("user.ser"))) {

oos.writeObject(new User("Alice", 25));

}

// 读取对象

try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream("user.ser"))) {

User user = (User) ois.readObject();

System.out.println(user.getName());

}

**注意事项**：
- 对象必须实现 `Serializable` 接口（标记接口）。
- `serialVersionUID` 用于版本控制，不指定时 JVM 自动生成，但建议显式声明。
- `transient` 字段不会被序列化。
- 静态字段不属于对象，不会被序列化。

---

### 5️⃣ NIO Overview · NIO 概述

NIO (Non-blocking I/O) 是 Java 1.4 引入的新 I/O 模型，核心组件：

| Component | Description · 说明 |
|-----------|--------------------|
| Channel | 双向通道，可读可写（如 FileChannel, SocketChannel） |
| Buffer | 缓冲区，存储数据（如 ByteBuffer, CharBuffer） |
| Selector | 选择器，监控多个 Channel 的事件（仅网络 I/O） |

**与 BIO 的区别**：

| Feature | BIO (Blocking I/O) | NIO (Non-blocking I/O) |
|---------|--------------------|------------------------|
| 模型 | 面向流（Stream） | 面向缓冲区（Buffer） |
| 阻塞 | 阻塞（read/write 阻塞线程） | 非阻塞（可设置） |
| 多路复用 | 无 | Selector 单线程管理多连接 |
| 适用场景 | 连接数少、低并发 | 连接数多、高并发 |

---

### 6️⃣ Channel & Buffer · 通道与缓冲区

java

// 文件读写（FileChannel）

try (RandomAccessFile file = new RandomAccessFile("data.txt", "rw");

FileChannel channel = file.getChannel()) {

// 写入
ByteBuffer buffer = ByteBuffer.allocate(1024);
buffer.put("Hello, NIO!".getBytes());
buffer.flip();                      // 切换为读模式
channel.write(buffer);

// 读取
buffer.clear();                     // 清空缓冲区
int bytesRead = channel.read(buffer);
buffer.flip();
byte[] data = new byte[bytesRead];
buffer.get(data);
System.out.println(new String(data));

}

// 直接缓冲区（DirectBuffer，零拷贝）

ByteBuffer directBuf = ByteBuffer.allocateDirect(1024);  // 堆外内存

**Buffer 核心方法**：
- `flip()`：写模式 → 读模式（position 置 0，limit 置原 position）
- `clear()`：读模式 → 写模式（position 置 0，limit 置 capacity）
- `compact()`：压缩未读完的数据
- `rewind()`：重新读取（position 置 0，limit 不变）

---

### 7️⃣ Selector · 选择器（网络 I/O）

java

// 服务端示例（非阻塞）

ServerSocketChannel serverChannel = ServerSocketChannel.open();

serverChannel.bind(new InetSocketAddress(8080));

serverChannel.configureBlocking(false);          // 非阻塞模式

Selector selector = Selector.open();

serverChannel.register(selector, SelectionKey.OP_ACCEPT);  // 注册接受事件

while (true) {

selector.select();                             // 阻塞直到有事件

Set<SelectionKey> keys = selector.selectedKeys();

Iterator<SelectionKey> iter = keys.iterator();

while (iter.hasNext()) {

SelectionKey key = iter.next();

if (key.isAcceptable()) {

SocketChannel client = serverChannel.accept();

client.configureBlocking(false);

client.register(selector, SelectionKey.OP_READ);

} else if (key.isReadable()) {

SocketChannel client = (SocketChannel) key.channel();

ByteBuffer buf = ByteBuffer.allocate(256);

client.read(buf);

// 处理数据

}

iter.remove();

}

}

**注意事项**：
- Selector 仅适用于网络 I/O（SocketChannel），不适用于文件 I/O。
- 一个线程可以管理成千上万个连接，是高并发服务器的核心。

---

### 8️⃣ NIO.2 (Java 7+) · 增强的文件操作

java

// Path 和 Files

Path path = Paths.get("/tmp", "test.txt");

Files.createDirectories(path.getParent());       // 创建目录

Files.write(path, "Hello".getBytes());           // 写入

String content = Files.readString(path);         // 读取全部内容 (Java 11+)

List<String> lines = Files.readAllLines(path);   // 按行读取

// 遍历目录

Files.walk(Paths.get("/var/log"))

.filter(p -> p.toString().endsWith(".log"))

.forEach(System.out::println);

// 文件属性

long size = Files.size(path);

FileTime lastModified = Files.getLastModifiedTime(path);

// 内存映射文件（零拷贝）

try (FileChannel channel = (FileChannel) Files.newByteChannel(path, StandardOpenOption.READ)) {

MappedByteBuffer mapped = channel.map(FileChannel.MapMode.READ_ONLY, 0, channel.size());

// 直接操作 mapped 缓冲区，无需 read() 调用

}

---

## 📂 Code Examples · 代码示例

All runnable code examples are located in the [`src/`](./src/) directory:

| File | Description |
|------|-------------|
| `ByteStreamDemo.java` | FileInputStream/OutputStream, BufferedInputStream/OutputStream |
| `CharStreamDemo.java` | FileReader/Writer, BufferedReader/Writer, encoding |
| `ObjectStreamDemo.java` | Serialization, ObjectInputStream/OutputStream |
| `FileChannelDemo.java` | FileChannel read/write, ByteBuffer |
| `SelectorDemo.java` | Non-blocking server using Selector |
| `Nio2Demo.java` | Path, Files, walk, memory-mapped file |

---

## ❓ Interview Questions with Answers · 面试题（附答案）

### I/O 基础
1. **字节流和字符流的区别？**
    - **答**：字节流以字节为单位处理数据（InputStream/OutputStream），适合二进制文件；字符流以字符为单位处理数据（Reader/Writer），适合文本文件，内部自动处理字符编码转换。

2. **BufferedInputStream 的作用是什么？**
    - **答**：BufferedInputStream 内部维护一个 8KB 的缓冲区，当调用 read() 时先从缓冲区读取，缓冲区空了才从磁盘读取一批数据，减少系统调用次数，显著提升 I/O 性能。

3. **try-with-resources 的原理？**
    - **答**：try-with-resources 是 Java 7 引入的语法糖，要求资源类实现 `AutoCloseable` 接口。编译时会自动生成 finally 块调用 close() 方法，并且会抑制 close() 抛出的异常（如果 try 块已抛出异常），避免异常掩盖。

### 序列化
4. **什么是 serialVersionUID？如果不指定会怎样？**
    - **答**：serialVersionUID 是序列化版本号，用于反序列化时验证类的版本一致性。如果不指定，JVM 会根据类的结构自动生成一个 UID。如果类结构发生变化（如增减字段），自动生成的 UID 会改变，导致反序列化失败。因此建议显式声明。

5. **transient 关键字的作用？**
    - **答**：transient 修饰的字段不会被序列化。例如密码、敏感数据或可以从其他字段计算出来的数据可以标记为 transient。

### NIO
6. **BIO、NIO、AIO 的区别？**
    - **答**：BIO（Blocking I/O）是同步阻塞，每个连接需要一个线程；NIO（Non-blocking I/O）是同步非阻塞，使用 Selector 多路复用，一个线程管理多个连接；AIO（Asynchronous I/O）是异步非阻塞，操作系统完成 I/O 后回调通知应用程序。

7. **NIO 的 Buffer 的 flip() 和 clear() 有什么区别？**
    - **答**：`flip()` 将写模式切换为读模式，设置 limit 为当前 position，position 置 0；`clear()` 将读模式切换为写模式，position 置 0，limit 置 capacity。`flip()` 用于写完数据后准备读取，`clear()` 用于读完数据后准备再次写入。

8. **Selector 的 select() 方法返回后，为什么需要 iterator.remove()？**
    - **答**：select() 返回的 SelectedKeys 集合不会自动移除已处理的 key，如果不手动 remove()，下次 select() 时相同的 key 会再次出现，导致重复处理。

9. **什么是零拷贝（Zero-Copy）？Java 中如何实现？**
    - **答**：零拷贝是指在数据传输过程中，数据从磁盘到网络（或反之）时，避免在内核空间和用户空间之间来回拷贝。Java 中通过 `FileChannel.transferTo()` / `transferFrom()` 方法实现，利用操作系统的 sendfile 系统调用，直接将数据从文件通道传输到 Socket 通道。

### NIO.2
10. **Files.walk() 和 Files.list() 的区别？**
    - **答**：`Files.list()` 只遍历当前目录的一级子目录/文件，返回 Stream<Path>；`Files.walk()` 递归遍历所有子目录，返回 Stream<Path>，可以通过 maxDepth 参数限制深度。

11. **内存映射文件（MappedByteBuffer）的优点和缺点？**
    - **答**：优点：读写速度快（直接操作内存，无需系统调用），适合大文件；缺点：占用虚拟内存，文件大小受限于虚拟地址空间，关闭文件后映射仍然存在直到 GC。

---

## 🇨🇳 中文说明

本目录覆盖了 Java I/O 和 NIO 的核心知识，包括字节流/字符流、缓冲流、对象流、NIO 的 Channel/Buffer/Selector、NIO.2 文件操作等。每个主题都配有带中文注释的代码示例和带答案的面试题。代码示例在 `src/` 目录下，可以直接编译运行。

---

*I/O is the bridge between your application and the outside world.* 🌉