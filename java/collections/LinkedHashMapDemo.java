import java.util.*;

/**
 * LinkedHashMap 演示：LRU 缓存
 */
public class LinkedHashMapDemo {
    public static void main(String[] args) {
        // LRU 缓存：最多缓存3个元素
        LinkedHashMap<String, String> lru = new LinkedHashMap<>(16, 0.75f, true) {
            @Override
            protected boolean removeEldestEntry(Map.Entry<String, String> eldest) {
                return size() > 3;
            }
        };

        lru.put("a", "1");
        lru.put("b", "2");
        lru.put("c", "3");
        System.out.println("Initial: " + lru.keySet());  // [a, b, c]

        lru.get("a");               // 访问 a，a 移到末尾
        System.out.println("After access a: " + lru.keySet()); // [b, c, a]

        lru.put("d", "4");          // 超出容量，移除最老的 b
        System.out.println("After put d: " + lru.keySet());    // [c, a, d]
    }
}