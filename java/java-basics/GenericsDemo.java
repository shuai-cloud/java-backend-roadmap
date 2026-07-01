import java.util.*;

/**
 * 泛型演示
 */
public class GenericsDemo {

    // 泛型类
    static class Box<T> {
        private T content;
        public void set(T content) { this.content = content; }
        public T get() { return content; }
    }

    // 泛型方法
    public static <T> T getMiddle(T... a) {
        return a[a.length / 2];
    }

    public static void main(String[] args) {
        // 泛型类
        Box<String> stringBox = new Box<>();
        stringBox.set("Hello");
        System.out.println(stringBox.get());

        Box<Integer> intBox = new Box<>();
        intBox.set(123);
        System.out.println(intBox.get());

        // 泛型方法
        String middle = getMiddle("A", "B", "C");
        System.out.println("Middle: " + middle);

        // 通配符
        List<? extends Number> numbers = new ArrayList<Integer>();
        // numbers.add(1);  // 编译错误，不能添加元素（除了 null）
        Number n = numbers.get(0);  // 可以读取

        List<? super Integer> integers = new ArrayList<Number>();
        integers.add(1);            // 可以添加 Integer 或其子类
        Object obj = integers.get(0); // 读取时只能赋给 Object

        // 类型擦除演示：运行时无法区分 Box<String> 和 Box<Integer>
        System.out.println(stringBox.getClass() == intBox.getClass()); // true
    }
}