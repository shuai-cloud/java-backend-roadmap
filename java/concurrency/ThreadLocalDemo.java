/**
 * ThreadLocal 演示
 */
public class ThreadLocalDemo {
    // 每个线程持有自己的计数器
    private static ThreadLocal<Integer> counter = ThreadLocal.withInitial(() -> 0);

    public static void main(String[] args) {
        for (int i = 0; i < 3; i++) {
            new Thread(() -> {
                // 每个线程独立累加
                for (int j = 0; j < 5; j++) {
                    counter.set(counter.get() + 1);
                    System.out.println(Thread.currentThread().getName() + " counter: " + counter.get());
                }
                // 使用后务必 remove，避免内存泄漏
                counter.remove();
            }).start();
        }
    }
}