import java.util.HashMap;

public class HashMapDemo {

    public static void main(String[] args) {

        // Create a HashMap
        // 创建一个 HashMap
        HashMap<String, Integer> map = new HashMap<>();

        // Insert key-value pairs
        // 插入键值对
        map.put("apple", 1);
        map.put("banana", 2);
        map.put("orange", 3);

        // Retrieve value by key
        // 根据 key 获取 value
        System.out.println("apple = " + map.get("apple"));

        // Update value
        // 更新 value（key 相同会覆盖）
        map.put("apple", 100);

        System.out.println("updated apple = " + map.get("apple"));

        // Check if key exists
        // 判断 key 是否存在
        System.out.println("contains 'banana': " + map.containsKey("banana"));

        // Iterate through map
        // 遍历 HashMap
        for (String key : map.keySet()) {
            System.out.println(key + " -> " + map.get(key));
        }
    }
}
