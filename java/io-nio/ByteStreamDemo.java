import java.io.*;

/**
 * 字节流演示：文件复制
 */
public class ByteStreamDemo {
    public static void main(String[] args) throws IOException {
        // 创建临时文件
        File source = new File("/tmp/source.dat");
        File dest = new File("/tmp/dest.dat");

        // 写入测试数据
        try (FileOutputStream fos = new FileOutputStream(source)) {
            fos.write("Hello, Byte Stream!".getBytes());
        }

        // 1. 不使用缓冲流（直接读写）
        long start = System.nanoTime();
        try (FileInputStream fis = new FileInputStream(source);
             FileOutputStream fos = new FileOutputStream(dest)) {
            int b;
            while ((b = fis.read()) != -1) {  // 每次读一个字节，极慢
                fos.write(b);
            }
        }
        long end = System.nanoTime();
        System.out.println("Without buffer: " + (end - start) / 1_000_000 + " ms");

        // 2. 使用缓冲流
        start = System.nanoTime();
        try (BufferedInputStream bis = new BufferedInputStream(new FileInputStream(source));
             BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(dest))) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = bis.read(buffer)) != -1) {
                bos.write(buffer, 0, bytesRead);
            }
        }
        end = System.nanoTime();
        System.out.println("With buffer: " + (end - start) / 1_000_000 + " ms");

        // 清理
        source.delete();
        dest.delete();
    }
}