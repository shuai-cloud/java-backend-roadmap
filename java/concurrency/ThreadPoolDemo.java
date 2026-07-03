import java.util.concurrent.*;

/**
 * 线程池演示
 */
public class ThreadPoolDemo {
    public static void main(String[] args) throws Exception {
        // 1. 创建线程池
        ThreadPoolExecutor executor = new ThreadPoolExecutor(
                2,                      // corePoolSize
                5,                      // maximumPoolSize
                60,                     // keepAliveTime
                TimeUnit.SECONDS,
                new LinkedBlockingQueue<>(10),  // workQueue
                Executors.defaultThreadFactory(),
                new ThreadPoolExecutor.AbortPolicy()  // 拒绝策略
        );

        // 2. 提交任务
        for (int i = 0; i < 15; i++) {
            final int taskId = i;
            executor.execute(() -> {
                System.out.println(Thread.currentThread().getName() + " executing task " + taskId);
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            });
        }

        // 3. 使用 Callable 获取结果
        Future<String> future = executor.submit(() -> {
            Thread.sleep(500);
            return "Task result";
        });
        System.out.println("Future result: " + future.get());

        // 4. 关闭线程池
        executor.shutdown();
        // 等待所有任务完成
        executor.awaitTermination(10, TimeUnit.SECONDS);
        System.out.println("All tasks completed.");
    }
}
