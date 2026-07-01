/**
 * 面向对象演示：封装、继承、多态、抽象类、接口
 */
// 封装
class Person {
    private String name;
    private int age;

    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public String getName() { return name; }
    public int getAge() { return age; }
}

// 继承
class Student extends Person {
    private String studentId;

    public Student(String name, int age, String studentId) {
        super(name, age);       // 调用父类构造器
        this.studentId = studentId;
    }

    public String getStudentId() { return studentId; }
}

// 抽象类
abstract class Animal {
    abstract void sound();      // 抽象方法，子类必须实现
    void breathe() {            // 具体方法
        System.out.println("Breathing...");
    }
}

class Dog extends Animal {
    @Override
    void sound() {
        System.out.println("Woof!");
    }
}

// 接口
interface Flyable {
    void fly();                 // 默认 public abstract
    default void glide() {      // 默认方法 (Java 8+)
        System.out.println("Gliding...");
    }
}

class Bird implements Flyable {
    @Override
    public void fly() {
        System.out.println("Bird flying");
    }
}

public class OOPDemo {
    public static void main(String[] args) {
        // 封装
        Person p = new Person("Alice", 25);
        System.out.println(p.getName());

        // 继承
        Student s = new Student("Bob", 20, "S001");
        System.out.println(s.getName() + " - " + s.getStudentId());

        // 多态：父类引用指向子类对象
        Person personRef = new Student("Charlie", 22, "S002");
        System.out.println(personRef.getName());   // 调用父类方法，实际执行子类（Student）的 getName（继承自父类）

        // 抽象类
        Animal dog = new Dog();
        dog.sound();
        dog.breathe();

        // 接口
        Flyable bird = new Bird();
        bird.fly();
        bird.glide();   // 默认方法
    }
}