import java.io.*;
import lombok.Data;

/**
 * 对象流演示：序列化与反序列化
 */
public class ObjectStreamDemo {
    @Data
    static class User implements Serializable {
        private static final long serialVersionUID = 1L;
        private String name;
        private transient int age;  // transient 字段不会被序列化
        private String email;

        public User(String name, int age, String email) {
            this.name = name;
            this.age = age;
            this.email = email;
        }
    }

    public static void main(String[] args) throws Exception {
        File file = new File("/tmp/user.ser");

        // 序列化
        User user = new User("Alice", 25, "alice@example.com");
        try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(file))) {
            oos.writeObject(user);
        }
        System.out.println("Serialized: " + user);

        // 反序列化
        try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream(file))) {
            User deserialized = (User) ois.readObject();
            System.out.println("Deserialized: " + deserialized);
            System.out.println("Age (transient, should be 0): " + deserialized.getAge());
        }

        file.delete();
    }
}