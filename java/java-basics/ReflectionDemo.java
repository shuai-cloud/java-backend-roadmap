import java.lang.reflect.*;

/**
 * 反射演示
 */
public class ReflectionDemo {

    static class User {
        private String name;
        public User() {}
        public User(String name) { this.name = name; }
        private void secretMethod() {
            System.out.println("Secret method called");
        }
        public String getName() { return name; }
    }

    public static void main(String[] args) throws Exception {
        // 1. 获取 Class 对象
        Class<?> clazz = Class.forName("ReflectionDemo$User");  // 内部类使用 $ 分隔
        System.out.println("Class name: " + clazz.getName());

        // 2. 创建实例
        User user = (User) clazz.getDeclaredConstructor().newInstance();

        // 3. 访问私有字段
        Field field = clazz.getDeclaredField("name");
        field.setAccessible(true);          // 绕过 private 检查
        field.set(user, "Alice");
        System.out.println("Name via reflection: " + field.get(user));

        // 4. 调用私有方法
        Method method = clazz.getDeclaredMethod("secretMethod");
        method.setAccessible(true);
        method.invoke(user);

        // 5. 动态代理
        InvocationHandler handler = (proxy, m, args1) -> {
            System.out.println("Before method: " + m.getName());
            Object result = m.invoke(user, args1);
            System.out.println("After method");
            return result;
        };
        User proxyUser = (User) Proxy.newProxyInstance(
                User.class.getClassLoader(),
                new Class[]{User.class},
                handler);
        // 注意：User 是类不是接口，JDK 动态代理只能代理接口。这里仅为演示，实际上会抛异常。
        // 正确做法：定义一个接口 IUser，然后代理接口。
    }
}