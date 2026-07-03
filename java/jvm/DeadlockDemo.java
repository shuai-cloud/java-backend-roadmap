/**
 * 死锁模拟演示
 * 使用 jstack -l <PID> 可以检测到死锁
 */
public class DeadlockDemo {
    private static final Object LOCK_A = new Object();
    private static final Object LOCK_B = new Object();

    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(() -> {
            synchronized (LOCK_A) {
                System.out.println("Thread 1: holding lock A");
                try { Thread.sleep(100); } catch (InterruptedException e) {}
                synchronized (LOCK_B) {
                    System.out.println("Thread 1: holding lock A and B");
                }
            }
        });

        Thread t2 = new Thread(() -> {
            synchronized (LOCK_B) {
                System.out.println("Thread 2: holding lock B");
                try { Thread.sleep(100); } catch (InterruptedException e) {}
                synchronized (LOCK_A) {
                    System.out.println("Thread 2: holding lock A and B");
                }
            }
        });

        t1.start();
        t2.start();
        t1.join();
        t2.join();
    }
}