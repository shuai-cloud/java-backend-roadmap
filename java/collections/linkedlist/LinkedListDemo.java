package collections.linkedlist;

import java.util.LinkedList;

public class LinkedListDemo {

    public static void main(String[] args) {

        // Create LinkedList
        // 创建 LinkedList
        LinkedList<String> list = new LinkedList<>();

        // Add elements
        // 添加元素
        list.add("Java");
        list.add("Spring");
        list.add("Redis");

        // Add element at first position
        // 头插
        list.addFirst("MySQL");

        // Add element at last position
        // 尾插
        list.addLast("Kafka");

        // Access element
        // 获取元素
        System.out.println(list.get(0));

        // Remove first element
        // 删除头节点
        list.removeFirst();

        // Traverse
        // 遍历
        for (String item : list) {
            System.out.println(item);
        }
    }
}