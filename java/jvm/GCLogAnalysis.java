import java.util.ArrayList;
import java.util.List;

/**
 * GC 日志分析演示
 * 运行参数建议：-Xms128m -Xmx128m -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:gc.log
 */
public class GCLogAnalysis {
    public static void main(String[] args) throws InterruptedException {
        List<byte[]> list = new ArrayList<>();
        System.out.println("Starting GC analysis...");
        for (int i = 0; i < 1000; i++) {
            // 每次分配 100KB
            byte[] data = new byte[100 * 1024];
            list.add(data);
            Thread.sleep(10);
            if (i % 100 == 99) {
                // 每 100 次清理一半，触发 GC
                for (int j = 0; j < 50; j++) {
                    list.remove(0);
                }
                System.out.println("Iteration " + (i + 1) + ", list size: " + list.size());
            }
        }
        System.out.println("Done. Check gc.log for details.");
    }
}