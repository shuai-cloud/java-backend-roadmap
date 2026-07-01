/**
 * 枚举演示
 */
public class EnumDemo {

    // 简单枚举
    enum Color {
        RED, GREEN, BLUE
    }

    // 带字段和方法的枚举
    enum Status {
        PENDING(0, "待处理"),
        SUCCESS(1, "成功"),
        FAILURE(-1, "失败");

        private final int code;
        private final String description;

        Status(int code, String description) {
            this.code = code;
            this.description = description;
        }

        public int getCode() { return code; }
        public String getDescription() { return description; }
    }

    public static void main(String[] args) {
        // 基本使用
        Color c = Color.RED;
        System.out.println(c);

        // 遍历
        for (Color color : Color.values()) {
            System.out.println(color.ordinal() + ": " + color.name());
        }

        // 带字段的枚举
        Status s = Status.PENDING;
        System.out.println(s.getCode() + " - " + s.getDescription());

        // valueOf
        Status s2 = Status.valueOf("SUCCESS");
        System.out.println(s2);
    }
}