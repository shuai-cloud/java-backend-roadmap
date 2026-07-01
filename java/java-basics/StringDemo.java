/**
 * 字符串处理演示
 */
public class StringDemo {
    public static void main(String[] args) {
        // 字符串常量池
        String s1 = "hello";
        String s2 = "hello";
        String s3 = new String("hello");
        System.out.println(s1 == s2);       // true，指向常量池同一对象
        System.out.println(s1 == s3);       // false，堆中新对象

        // 字符串不可变性
        String original = "hello";
        String modified = original.toUpperCase();
        System.out.println(original);       // hello（原字符串不变）
        System.out.println(modified);       // HELLO

        // StringBuilder（线程不安全，性能好）
        StringBuilder sb = new StringBuilder();
        sb.append("Hello");
        sb.append(" ");
        sb.append("World");
        System.out.println(sb.toString());  // Hello World

        // StringBuffer（线程安全）
        StringBuffer buffer = new StringBuffer();
        buffer.append("Java");
        buffer.insert(4, " 8");
        System.out.println(buffer.toString()); // Java 8
    }
}