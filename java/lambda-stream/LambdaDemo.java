import java.util.*;
import java.util.function.*;

/**
 * Lambda 表达式、函数式接口、方法引用演示
 */
public class LambdaDemo {
    public static void main(String[] args) {
        // 1. Lambda 基本语法
        Runnable r = () -> System.out.println("Hello from lambda");
        new Thread(r).start();

        // 2. 函数式接口
        // Predicate
        Predicate<String> isEmpty = s -> s.isEmpty();
        System.out.println("isEmpty(''): " + isEmpty.test(""));
        System.out.println("isEmpty('a'): " + isEmpty.test("a"));

        // Consumer
        Consumer<String> printer = s -> System.out.println("Consuming: " + s);
        printer.accept("Hello");

        // Function
        Function<String, Integer> toLength = s -> s.length();
        System.out.println("Length of 'Hello': " + toLength.apply("Hello"));

        // Supplier
        Supplier<Double> random = () -> Math.random();
        System.out.println("Random: " + random.get());

        // 3. 方法引用
        List<String> names = Arrays.asList("Alice", "Bob", "Charlie");
        // 实例方法引用（任意对象）
        names.stream().map(String::toUpperCase).forEach(System.out::println);
        // 静态方法引用
        names.stream().map(Integer::parseInt); // 如果都是数字字符串
        // 构造方法引用
        Supplier<List<String>> listCreator = ArrayList::new;
        List<String> newList = listCreator.get();
    }
}