import java.util.concurrent.*;

/**
 * AQS 同步器演示：CountDownLatch 和 Semaphore
 */
public class AQSExample {
    public static void main(String[] args) throws Exception {
        // CountDownLatch：等待所有线程就绪
        int threadCount = 5;
        CountDownLatch latch = new CountDownLatch(threadCount);

        for (int i = 0; i < threadCount; i++) {
            new Thread(() -> {
                System.out.println(Thread.currentThread().getName() + " started");
                try {
                    Thread.sleep((long)(Math.random() * 1000));
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
                latch.countDown();
                System.out.println(Thread.currentThread().getName() + " finished");
            }).start();
        }

        latch.await();  // 主线程等待所有线程完成
        System.out.println("All threads finished. Main continues.");

        // Semaphore：限制并发访问数
        Semaphore semaphore = new Semaphore(3);  // 允许 3 个线程同时访问

        for (int i = 0; i < 10; i++) {
            new Thread(() -> {
                try {
                    semaphore.acquire();
                    System.out.println(Thread.currentThread().getName() + " acquired permit");
                    Thread.sleep(500);
                    System.out.println(Thread.currentThread().getName() + " releasing permit");
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                } finally {
                    semaphore.release();
                }
            }).start();
        }
    }
}