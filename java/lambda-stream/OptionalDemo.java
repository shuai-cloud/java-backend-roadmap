import java.util.*;

/**
 * Optional 演示
 */
public class OptionalDemo {
    public static void main(String[] args) {
        // 1. 创建
        Optional<String> empty = Optional.empty();
        Optional<String> nonNull = Optional.of("value");
        Optional<String> nullable = Optional.ofNullable(null);

        // 2. 判读和获取
        System.out.println("isPresent: " + nonNull.isPresent());
        System.out.println("orElse: " + empty.orElse("default"));
        System.out.println("orElseGet: " + empty.orElseGet(() -> computeDefault()));

        // 3. 转换
        Optional<Integer> length = nonNull.map(String::length);
        Optional<String> filtered = nonNull.filter(s -> s.length() > 3);
        System.out.println("Length: " + length.orElse(0));

        // 4. 安全使用
        String result = nullable.orElseThrow(() -> new IllegalArgumentException("Value is null"));

        // 5. 实战：避免 NPE
        Map<String, String> config = new HashMap<>();
        config.put("timeout", "5000");
        int timeout = Optional.ofNullable(config.get("timeout"))
                .map(Integer::parseInt)
                .orElse(1000);
        System.out.println("Timeout: " + timeout);
    }

    private static String computeDefault() {
        System.out.println("Computing default...");
        return "computed default";
    }
}