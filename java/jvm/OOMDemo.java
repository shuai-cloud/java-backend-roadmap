import java.util.ArrayList;
import java.util.List;

/**
 * OOM 模拟演示
 * 运行参数建议：-Xms32m -Xmx32m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp/heapdump.hprof
 */
public class OOMDemo {
    public static void main(String[] args) {
        // 模拟堆溢出
        List<byte[]> list = new ArrayList<>();
        try {
            while (true) {
                list.add(new byte[1024 * 1024]); // 每次 1MB
            }
        } catch (OutOfMemoryError e) {
            System.out.println("Heap OOM occurred after allocating " + list.size() + " MB");
        }

        // 模拟栈溢出（递归调用）
        try {
            stackOverflow();
        } catch (StackOverflowError e) {
            System.out.println("Stack overflow occurred");
        }
    }

    static int depth = 0;
    static void stackOverflow() {
        depth++;
        stackOverflow();
    }
}