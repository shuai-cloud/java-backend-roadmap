import java.util.*;
import java.util.stream.*;

/**
 * Collectors 高级用法演示
 */
public class CollectorsDemo {
    public static void main(String[] args) {
        List<String> words = Arrays.asList("apple", "banana", "apricot", "blueberry", "cherry");

        // 1. groupingBy
        Map<Character, List<String>> byFirstLetter = words.stream()
                .collect(Collectors.groupingBy(w -> w.charAt(0)));
        System.out.println("Grouped by first letter: " + byFirstLetter);

        // 2. groupingBy + downstream collector
        Map<Character, Long> countByFirstLetter = words.stream()
                .collect(Collectors.groupingBy(w -> w.charAt(0), Collectors.counting()));
        System.out.println("Count by first letter: " + countByFirstLetter);

        // 3. partitioningBy
        List<Integer> nums = Arrays.asList(1, 2, 3, 4, 5, 6);
        Map<Boolean, List<Integer>> evenOdd = nums.stream()
                .collect(Collectors.partitioningBy(n -> n % 2 == 0));
        System.out.println("Even: " + evenOdd.get(true));
        System.out.println("Odd: " + evenOdd.get(false));

        // 4. summarizing
        IntSummaryStatistics stats = nums.stream()
                .collect(Collectors.summarizingInt(Integer::intValue));
        System.out.println("Stats: sum=" + stats.getSum() + ", avg=" + stats.getAverage() +
                ", min=" + stats.getMin() + ", max=" + stats.getMax());

        // 5. joining
        String joined = words.stream()
                .collect(Collectors.joining(", ", "[", "]"));
        System.out.println("Joined: " + joined);
    }
}