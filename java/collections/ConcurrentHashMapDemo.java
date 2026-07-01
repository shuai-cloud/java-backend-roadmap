import java.util.concurrent.*;

/**
 * ConcurrentHashMap 演示：线程安全操作
 */
public class ConcurrentHashMapDemo {
    public static void main(String[] args) {
        ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();

        // 原子操作
        map.put("counter", 0);
        // 原子递增
        map.compute("counter", (k, v) -> v == null ? 1 : v + 1);
        System.out.println(map.get("counter")); // 1

        // putIfAbsent
        map.putIfAbsent("key", 100);
        map.putIfAbsent("key", 200);    // 不会覆盖
        System.out.println(map.get("key")); // 100

        // computeIfAbsent
        map.computeIfAbsent("newKey", k -> computeExpensiveValue(k));
        System.out.println(map.get("newKey"));
    }

    private static int computeExpensiveValue(String key) {
        // 模拟耗时计算
        return key.length() * 10;
    }
}