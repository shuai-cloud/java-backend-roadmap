/**
 * Java 基础语法演示
 * 包含：变量、数据类型、运算符、流程控制
 */
public class BasicSyntaxDemo {
    public static void main(String[] args) {
        // 1. 变量与数据类型
        int age = 25;                       // 基本类型 int
        double salary = 12500.50;           // 浮点数
        boolean isActive = true;            // 布尔
        char grade = 'A';                   // 字符
        String name = "Alice";              // 引用类型 String

        // 常量
        final double PI = 3.14159;

        // 2. 运算符
        int sum = age + 5;                  // 算术运算
        boolean isAdult = age >= 18;        // 比较运算
        boolean bothTrue = isActive && isAdult;  // 逻辑运算

        // 3. 流程控制
        // if-else
        if (age >= 65) {
            System.out.println("Senior");
        } else if (age >= 18) {
            System.out.println("Adult");
        } else {
            System.out.println("Minor");
        }

        // switch 表达式 (Java 14+)
        String category = switch (age) {
            case 0, 1, 2 -> "Baby";
            case 3, 4, 5 -> "Toddler";
            default -> "Other";
        };
        System.out.println("Category: " + category);

        // 循环
        for (int i = 0; i < 3; i++) {
            System.out.println("Loop: " + i);
        }

        // while
        int count = 0;
        while (count < 3) {
            System.out.println("While: " + count);
            count++;
        }

        // 数组
        int[] numbers = {10, 20, 30};
        for (int num : numbers) {
            System.out.println("Array element: " + num);
        }
    }
}