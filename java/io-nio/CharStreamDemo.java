import java.io.*;
import java.nio.charset.StandardCharsets;

/**
 * 字符流演示：文本文件读写
 */
public class CharStreamDemo {
    public static void main(String[] args) throws IOException {
        File file = new File("/tmp/text.txt");

        // 写入（使用 UTF-8 编码）
        try (BufferedWriter writer = new BufferedWriter(
                new OutputStreamWriter(new FileOutputStream(file), StandardCharsets.UTF_8))) {
            writer.write("你好，世界！");
            writer.newLine();
            writer.write("Hello, World!");
        }

        // 读取
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println(line);
            }
        }

        // 使用 Files 简便方法 (Java 11+)
        String content = Files.readString(file.toPath(), StandardCharsets.UTF_8);
        System.out.println("Content: " + content);

        file.delete();
    }
}