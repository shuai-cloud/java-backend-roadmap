import java.util.*;

/**
 * ArrayList 演示：扩容、增删改查、遍历
 */
public class ArrayListDemo {
    public static void main(String[] args) {
        // 1. 基本操作
        List<String> list = new ArrayList<>();
        list.add("A");
        list.add("B");
        list.add(1, "C");           // 在索引1插入
        System.out.println(list);   // [A, C, B]

        // 2. 随机访问
        String elem = list.get(2);  // O(1)
        System.out.println("elem at index 2: " + elem);

        // 3. 删除
        list.remove(1);             // 删除索引1的元素，后面的元素前移
        System.out.println("after remove: " + list);

        // 4. 遍历
        // for-each
        for (String s : list) {
            System.out.println(s);
        }
        // Iterator
        Iterator<String> it = list.iterator();
        while (it.hasNext()) {
            System.out.println(it.next());
        }
        // forEach (Java 8+)
        list.forEach(System.out::println);

        // 5. 扩容观察
        List<Integer> capDemo = new ArrayList<>(2);
        capDemo.add(1);
        capDemo.add(2);
        System.out.println("before add 3, capacity = 2");
        capDemo.add(3);             // 触发扩容，新容量 = 2 + 2>>1 = 3
        System.out.println("after add 3, capacity = 3 (实际内部已扩容)");
    }
}