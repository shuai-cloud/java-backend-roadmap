/**
 * 单例模式四种实现演示
 */
public class SingletonDemo {
    public static void main(String[] args) {
        // 验证单例
        LazySingleton s1 = LazySingleton.getInstance();
        LazySingleton s2 = LazySingleton.getInstance();
        System.out.println("Same instance: " + (s1 == s2));

        EnumSingleton.INSTANCE.doSomething();
    }
}

// 饿汉式
class EagerSingleton {
    private static final EagerSingleton INSTANCE = new EagerSingleton();
    private EagerSingleton() {}
    public static EagerSingleton getInstance() { return INSTANCE; }
}

// 懒汉式（双重检查锁定）
class LazySingleton {
    private static volatile LazySingleton instance;
    private LazySingleton() {}
    public static LazySingleton getInstance() {
        if (instance == null) {
            synchronized (LazySingleton.class) {
                if (instance == null) {
                    instance = new LazySingleton();
                }
            }
        }
        return instance;
    }
}

// 静态内部类
class HolderSingleton {
    private HolderSingleton() {}
    private static class Holder {
        static final HolderSingleton INSTANCE = new HolderSingleton();
    }
    public static HolderSingleton getInstance() { return Holder.INSTANCE; }
}

// 枚举
enum EnumSingleton {
    INSTANCE;
    public void doSomething() { System.out.println("Doing something"); }
}