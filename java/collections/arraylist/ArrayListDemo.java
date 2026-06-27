import java.util.ArrayList;

public class ArrayListDemo {

    public static void main(String[] args) {

        // Create ArrayList
        // 创建 ArrayList
        ArrayList<String> list = new ArrayList<>();

        // Add elements
        // 添加元素
        list.add("Java");
        list.add("Spring");
        list.add("MySQL");

        // Get element
        // 获取元素
        System.out.println(list.get(0));

        // Update element
        // 修改元素
        list.set(1, "Spring Boot");

        // Remove element
        // 删除元素
        list.remove("MySQL");

        // Iterate list
        // 遍历集合
        for (String item : list) {
            System.out.println(item);
        }
    }
}