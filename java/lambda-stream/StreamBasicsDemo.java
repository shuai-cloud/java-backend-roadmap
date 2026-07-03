import java.util.*;
import java.util.stream.*;

/**
 * Stream API 基础演示
 */
public class StreamBasicsDemo {
    public static void main(String[] args) {
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

        // 1. 中间操作
        List<Integer> evenSquares = numbers.stream()
                .filter(n -> n % 2 == 0)          // 偶数
                .map(n -> n * n)                  // 平方
                .sorted(Comparator.reverseOrder()) // 降序
                .collect(Collectors.toList());
        System.out.println("Even squares desc: " + evenSquares);

        // 2. 终端操作
        long count = numbers.stream().count();
        System.out.println("Count: " + count);

        Optional<Integer> sum = numbers.stream().reduce(Integer::sum);
        System.out.println("Sum: " + sum.orElse(0));

        boolean allPositive = numbers.stream().allMatch(n -> n > 0);
        System.out.println("All positive: " + allPositive);

        // 3. flatMap 示例
        List<List<String>> nested = Arrays.asList(
                Arrays.asList("a", "b"),
                Arrays.asList("c", "d", "e"),
                Arrays.asList("f")
        );
        List<String> flattened = nested.stream()
                .flatMap(List::stream)
                .collect(Collectors.toList());
        System.out.println("Flattened: " + flattened);

        // 4. 无限流
        List<Integer> first10Even = Stream.iterate(0, n -> n + 2)
                .limit(10)
                .collect(Collectors.toList());
        System.out.println("First 10 evens: " + first10Even);
    }
}