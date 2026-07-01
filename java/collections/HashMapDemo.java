import java.util.*;

/**
 * HashMap 演示：基本操作、遍历、扩容观察
 */
public class HashMapDemo {
    public static void main(String[] args) {
        // 1. 基本操作
        Map<String, Integer> map = new HashMap<>();
        map.put("apple", 10);
        map.put("banana", 20);
        map.put("orange", 30);

        // getOrDefault
        int value = map.getOrDefault("grape", 0);
        System.out.println("grape: " + value);

        // 2. 遍历 Entry
        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            System.out.println(entry.getKey() + " -> " + entry.getValue());
        }

        // 3. 遍历 Key
        for (String key : map.keySet()) {
            System.out.println(key);
        }

        // 4. 遍历 Value
        for (Integer val : map.values()) {
            System.out.println(val);
        }

        // 5. 扩容观察：初始容量2，负载因子0.75，阈值=2 * 0.75=1.5≈1
        // 当放入第2个元素时触发扩容
        Map<Integer, String> smallMap = new HashMap<>(2);
        smallMap.put(1, "one");
        System.out.println("size=1, 未扩容");
        smallMap.put(2, "two");    // 此时size=2 > 1.5，触发扩容到4
        System.out.println("size=2, 已扩容");

        // 6. 计算 hash 值（演示）
        String key = "hello";
        int h = key.hashCode();
        int index = (h ^ (h >>> 16)) & (16 - 1);  // 假设容量16
        System.out.println("index for 'hello': " + index);
    }
}